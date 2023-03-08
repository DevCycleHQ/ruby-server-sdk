require 'wasmtime'
require 'date'
require 'bigdecimal'
require 'sorbet-runtime'

require_relative 'dvc_options'
require_relative 'platform_data'
require_relative 'events_payload'
require_relative 'config_manager'

module DevCycle
  class LocalBucketing
    extend T::Sig

    attr_reader :options
    attr_accessor :initialized
    attr_accessor :has_config

    @@rand = Random.new(seed = Random.new_seed)
    @@engine = Wasmtime::Engine.new

    @@wasmmodule = Wasmtime::Module.from_file(@@engine, "#{__dir__}/bucketing-lib.release.wasm")
    @@wasi_ctx = Wasmtime::WasiCtxBuilder.new
                                         .inherit_stdout
                                         .inherit_stderr
                                         .set_argv(ARGV)
                                         .set_env(ENV)
    @@store = Wasmtime::Store.new(@@engine, wasi_ctx: @@wasi_ctx)
    @@linker = Wasmtime::Linker.new(@@engine, wasi: true)

    @@linker.func_new("env", "Date.now", [], [:f64]) do |_caller|
      DateTime.now.strftime("%Q").to_i
    end

    inline_read_asc_string = lambda { |address|
      raw_bytes = @@memory.read(address - 4, 4).bytes.reverse
      message_len = 0
      raw_bytes.each { |j|
        message_len = (message_len << 8) + (j & 0xFF)
      }
      length = message_len
      result = ""
      i = 0
      while i < length
        result += @@memory.read(address + i, 1)
        i += 2
      end
      result
    }

    @@stack_tracer = lambda {}

    @@linker.func_new("env", "abort", [:i32, :i32, :i32, :i32], []) do |_caller, messagePtr, filenamePtr, lineNum, colNum|

      exception_message = ""
      exception_filename = ""

      [messagePtr, filenamePtr].each { |m|
        result = inline_read_asc_string.call(m)
        if m == messagePtr
          exception_message = result
        else
          if m == filenamePtr
            exception_filename = result
          end
        end
      }
      @@stack_tracer.call("WASM Exception: #{exception_message} - #{exception_filename} #{lineNum}:#{colNum}")
    end

    @@linker.func_new("env", "console.log", [:i32], []) do |_caller, messagePtr|
      @logger.info(inline_read_asc_string.call(messagePtr))
    end

    @@linker.func_new("env", "seed", [], [:f64]) do |_caller|
      @@rand.rand(1.0) * DateTime.now.strftime("%Q").to_i

    end

    @@instance = @@linker.instantiate(@@store, @@wasmmodule)
    @@memory = @@instance.export("memory").to_memory

    sig { params(
      sdkkey: String,
      options: DVCOptions,
      wait_for_init: T::Boolean
    ).void }
    def initialize(sdkkey, options, wait_for_init)
      @initialized = false
      @has_config = false
      @sdkkey = sdkkey
      @options = options
      @logger = options.logger
      set_sdk_key_internal(sdkkey)
      platform_data = PlatformData.new('server', VERSION, RUBY_VERSION, nil, 'Ruby', Socket.gethostname)
      set_platform_data(platform_data)
      @config_manager = ConfigManager.new(@sdkkey, self, wait_for_init)
    end

    def close
      @config_manager.close
      @config_manager = nil
    end

    sig { params(user: UserData).returns(BucketedUserConfig) }
    def generate_bucketed_config(user)
      user_addr = malloc_asc_string(user.to_json)
      @@stack_tracer = lambda { |message| raise message }
      config_addr = @@instance.invoke("generateBucketedConfigForUser", @sdkKeyAddr, user_addr)
      bucketed_config_json = read_asc_string(config_addr)
      bucketed_config_hash = Oj.load(bucketed_config_json)

      BucketedUserConfig.new(bucketed_config_hash['project'],
                             bucketed_config_hash['environment'],
                             bucketed_config_hash['features'],
                             bucketed_config_hash['featureVariationMap'],
                             bucketed_config_hash['variableVariationMap'],
                             bucketed_config_hash['variables'],
                             bucketed_config_hash['knownVariableKeys'])
    end

    sig { returns(T::Array[EventsPayload]) }
    def flush_event_queue
      @@stack_tracer = lambda { |message| raise message }
      payload_addr = @@instance.invoke("flushEventQueue", @sdkKeyAddr)
      raw_json = read_asc_string(payload_addr)
      raw_payloads = Oj.load(raw_json)

      if raw_payloads == nil
        return []
      end
      raw_payloads.map { |raw_payload| EventsPayload.new(raw_payload["records"], raw_payload["payloadId"], raw_payload["eventCount"]) }
    end

    sig { returns(Integer) }
    def check_event_queue_size
      @@stack_tracer = lambda { |message| raise message }
      @@instance.invoke("eventQueueSize", @sdkKeyAddr)
    end

    sig { params(payload_id: String).returns(NilClass) }
    def on_payload_success(payload_id)
      payload_addr = malloc_asc_string(payload_id)
      @@stack_tracer = lambda { |message| raise message }
      @@instance.invoke("onPayloadSuccess", @sdkKeyAddr, payload_addr)
    end

    sig { params(user: UserData, event: Event).returns(NilClass) }
    def queue_event(user, event)
      begin
        user_addr = malloc_asc_string(Oj.dump(user))
        asc_pin(user_addr)
        event_addr = malloc_asc_string(Oj.dump(event))
        @@stack_tracer = lambda { |message| raise message }
        @@instance.invoke("queueEvent", @sdkKeyAddr, user_addr, event_addr)
      ensure
        asc_unpin(user_addr)
      end
    end

    sig { params(event: Event, bucketeduser: T.nilable(BucketedUserConfig)).returns(NilClass) }
    def queue_aggregate_event(event, bucketeduser)
      begin
        variable_variation_map =
          if !bucketeduser.nil?
            bucketeduser.variable_variation_map
          else
            {}
          end
        varmap_addr = malloc_asc_string(Oj.dump(variable_variation_map))
        asc_pin(varmap_addr)
        event_addr = malloc_asc_string(Oj.dump(event))
        @@stack_tracer = lambda { |message| raise message }
        @@instance.invoke("queueAggregateEvent", @sdkKeyAddr, event_addr, varmap_addr)
      ensure
        asc_unpin(varmap_addr)
      end
    end

    sig { params(payload_id: String, retryable: Object).returns(NilClass) }
    def on_payload_failure(payload_id, retryable)
      payload_addr = malloc_asc_string(payload_id)
      @@stack_tracer = lambda { |message| raise message }
      @@instance.invoke("onPayloadFailure", @sdkKeyAddr, payload_addr, retryable ? 1 : 0)
    end

    sig { params(config: String).returns(NilClass) }
    def store_config(config)
      config_addr = malloc_asc_string(config)
      @@stack_tracer = lambda { |message| raise message }
      @@instance.invoke("setConfigData", @sdkKeyAddr, config_addr)
    end

    sig { params(options: EventQueueOptions).returns(NilClass) }
    def init_event_queue(options)
      options_json = Oj.dump(options)
      options_addr = malloc_asc_string(options_json)
      @@stack_tracer = lambda { |message| raise message }
      @@instance.invoke("initEventQueue", @sdkKeyAddr, options_addr)
    end

    sig { params(customdata: Hash).returns(NilClass) }
    def set_client_custom_data(customdata)
      customdata_json = Oj.dump(customdata)
      customdata_addr = malloc_asc_string(customdata_json)
      @@stack_tracer = lambda { |message| raise message }
      @@instance.invoke("setClientCustomData", customdata_addr)
    end

    private

    sig { params(platformdata: PlatformData).returns(NilClass) }
    def set_platform_data(platformdata)
      platformdata_json = Oj.dump(platformdata)
      platformdata_addr = malloc_asc_string(platformdata_json)
      @@stack_tracer = lambda { |message| raise message }
      @@instance.invoke("setPlatformData", platformdata_addr)
    end

    def set_sdk_key_internal(sdkKey)
      addr = malloc_asc_string(sdkKey)
      @sdkKeyAddr = addr
      asc_pin(addr)
    end

    def asc_pin(addr)
      @@instance.invoke("__pin", addr)
    end

    def asc_unpin(addr)
      @@instance.invoke("__unpin", addr)
    end

    # @param [String] string utf8 string to allocate
    # @return [Integer] address to WASM String
    sig { params(string: String).returns(Integer) }
    def malloc_asc_string(string)
      wasm_object_id = 1
      @@stack_tracer = lambda { |message| raise message }
      wasm_new = @@instance.export("__new").to_func
      utf8_bytes = string.bytes
      byte_len = utf8_bytes.length

      start_addr = wasm_new.call(byte_len * 2, wasm_object_id)
      i = 0
      while i < byte_len
        @@stack_tracer = lambda { |message| raise message }
        @@memory.write(start_addr + (i * 2), [utf8_bytes[i]].pack('U'))
        i += 1
      end
      start_addr
    end

    # @param [Integer] address start address of string.
    # @return [String] resulting string
    sig { params(address: Integer).returns(String) }
    def read_asc_string(address)
      @@stack_tracer = lambda { |message| raise message }
      raw_bytes = @@memory.read(address - 4, 4).bytes.reverse
      len = 0
      raw_bytes.each { |j|
        len = (len << 8) + (j & 0xFF)
      }
      result = ""
      i = 0
      while i < len
        @@stack_tracer = lambda { |message| raise message }
        result += @@memory.read(address + i, 1)
        i += 2
      end
      result
    end
  end
end

