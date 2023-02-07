require 'wasmtime'
require 'date'
require 'bigdecimal'
require 'sorbet-runtime'

require_relative 'dvc_options'
require_relative 'platform_data'
require_relative 'events_payload'

# Temp commenting out the module for testing within the file raw.
module DevCycle
  class LocalBucketing
    extend T::Sig

    @@rand = Random.new(seed = Random.new_seed)
    @@engine = Wasmtime::Engine.new
    @@wasmmodule = Wasmtime::Module.from_file(@@engine, "/Users/jamiesinn/git/ruby-server-sdk/lib/devcycle-ruby-server-sdk/localbucketing/bucketing-lib.release.wasm")
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

    @@linker.func_new("env", "abort", [:i32, :i32, :i32, :i32], []) do |_caller, messagePtr, filenamePtr, lineNum, colNum|

      exception_message = ""
      exception_filename = ""

      [messagePtr, filenamePtr].each { |m|
        raw_bytes = @@memory.read(m - 4, 4).bytes.reverse
        message_len = 0
        raw_bytes.each { |j|
          message_len = (message_len << 8) + (j & 0xFF)
        }
        length = message_len
        result = ""
        i = 0
        while i < length
          result += @@memory.read(m + i, 1)
          i += 2
        end
        if m == messagePtr
          exception_message = result
        else
          if m == filenamePtr
            exception_filename = result
          end
        end
      }

      STDERR.puts("WASM Exception: #{exception_message} - #{exception_filename} #{lineNum}:#{colNum}")
      exit(100)
    end

    @@linker.func_new("env", "console.log", [:i32], []) do |_caller, messagePtr|
      message = read_wasm_string(messagePtr)

      [messagePtr].each { |m|
        raw_bytes = @@memory.read(m - 4, 4).bytes.reverse
        message_len = 0
        raw_bytes.each { |j|
          message_len = (message_len << 8) + (j & 0xFF)
        }
        length = message_len
        result = ""
        i = 0
        while i < length
          result += @@memory.read(m + i, 1)
          i += 2
        end
        STDOUT.puts(message)
      }
    end

    @@linker.func_new("env", "seed", [], [:f64]) do |_caller|
      @@rand.rand(1.0) * DateTime.now.strftime("%Q").to_i

    end

    @@instance = @@linker.instantiate(@@store, @@wasmmodule)
    @@memory = @@instance.export("memory").to_memory

    sig { params(sdkkey: String, options: DVCOptions).returns(NilClass) }
    def initialize(sdkkey, options)
      @sdkkey = sdkkey
      @options = options

      # Set Platform Data
      # Initialize the Event Queue
      # Initialize Config Polling
      platform_data = Oj.dump(DevCycle::PlatformData.new('server', '1.0.0', RUBY_VERSION, nil, 'Ruby', Socket.gethostname))
      set_platform_data(platform_data)

      init_event_queue(Oj.dump(options.event_queue_options))
    end

    sig { params(user: String).returns(String) }
    def generate_bucketed_config(user)
      sdkkey_addr = malloc_wasm_string(@sdkkey)
      user_addr = malloc_wasm_string(user)
      config_addr = @@instance.invoke("generateBucketedConfigForUser", sdkkey_addr, user_addr)
      bucketed_config_json = read_wasm_string(config_addr)

    end

    sig { returns(EventsPayload) }
    def flush_event_queue
      sdkkey_addr = malloc_wasm_string(@sdkkey)
      payload_addr = @@instance.invoke("flushEventQueue", sdkkey_addr)
      raw_json = read_wasm_string(payload_addr)
      raw_payload = Oj.load(raw_json)[0]

      puts(raw_json)
      payload = EventsPayload.new(raw_payload["records"],
                                  raw_payload["payloadId"],
                                  raw_payload["eventCount"])
      payload
    end

    sig { returns(Integer) }
    def check_event_queue_size
      sdkkey_addr = malloc_wasm_string(@sdkkey)
      @@instance.invoke("eventQueueSize", sdkkey_addr)
    end

    sig { params(payload_id: String) }
    def on_payload_success(payload_id)
      sdkkey_addr = malloc_wasm_string(@sdkkey)
      payload_addr = malloc_wasm_string(payload_id)
      @@instance.invoke("onPayloadSuccess", sdkkey_addr, payload_addr)
    end

    sig { params(user: String, event: String).returns(NilClass) }
    def queue_event(user, event)
      sdkkey_addr = malloc_wasm_string(@sdkkey)
      user_addr = malloc_wasm_string(user)
      event_addr = malloc_wasm_string(event)
      @@instance.invoke("queueEvent", sdkkey_addr, user_addr, event_addr)
    end

    def queue_aggregate_event(event, bucketeduser)
      sdkkey_addr = malloc_wasm_string(@sdkkey)
      user_addr = malloc_wasm_string(bucketeduser)
      varmap_addr = malloc_wasm_string(bucketeduser.variation_map)
      event_addr = malloc_wasm_string(event)
      @@instance.invoke("queueAggregateEvent", sdkkey_addr, user_addr, event_addr, varmap_addr)
    end

    sig { params(payload_id: String, retryable: TrueClass | FalseClass).returns(NilClass) }
    def on_payload_failure(payload_id, retryable)
      sdkkey_addr = malloc_wasm_string(@sdkkey)
      payload_addr = malloc_wasm_string(payload_id)
      @@instance.invoke("onPayloadFailure", sdkkey_addr, payload_addr, retryable ? 1 : 0)
    end

    sig { params(sdkkey: String, config: String).returns(NilClass) }
    def store_config(sdkkey, config)
      sdkkey_addr = malloc_wasm_string(sdkkey)
      config_addr = malloc_wasm_string(config)
      @@instance.invoke("setConfigData", sdkkey_addr, config_addr)
    end

    private

    sig { params(platformdata: String).returns(NilClass) }
    def set_platform_data(platformdata)
      platformdata_addr = malloc_wasm_string(platformdata)
      @@instance.invoke("setPlatformData", platformdata_addr)
    end

    sig { params(options: String).returns(NilClass) }
    def init_event_queue(options)
      sdkkey_addr = malloc_wasm_string(@sdkkey)
      options_addr = malloc_wasm_string(options.to_s)
      @@instance.invoke("initEventQueue", sdkkey_addr, options_addr)
    end

    # @param [String] string utf8 string to allocate
    # @return [Integer] address to WASM String
    sig { params(string: String).returns(Integer) }
    def malloc_wasm_string(string)
      wasm_object_id = 1
      wasm_new = @@instance.export("__new").to_func
      utf8_bytes = string.encode("iso-8859-1").force_encoding("utf-8").bytes
      byte_len = utf8_bytes.length

      start_addr = wasm_new.call(byte_len * 2, wasm_object_id)
      i = 0
      while i < byte_len
        @@memory.write(start_addr + (i * 2), [utf8_bytes[i]].pack('U'))
        i += 1
      end
      start_addr
    end

    # @param [Integer] address start address of string.
    # @return [String] resulting string
    sig { params(address: Integer).returns(String) }
    def read_wasm_string(address)
      raw_bytes = @@memory.read(address - 4, 4).bytes.reverse
      len = 0
      raw_bytes.each { |j|
        len = (len << 8) + (j & 0xFF)
      }
      result = ""
      i = 0
      while i < len
        result += @@memory.read(address + i, 1)
        i += 2
      end
      result
    end
  end
end

