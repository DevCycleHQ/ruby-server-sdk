require 'wasmtime'
require 'date'
require 'bigdecimal'
require 'sorbet-runtime'

require_relative 'options'
require_relative 'platform_data'
require_relative 'events_payload'
require_relative 'config_manager'

module DevCycle
  class LocalBucketing
    extend T::Sig

    attr_reader :options
    attr_reader :variable_type_codes
    attr_accessor :initialized
    attr_accessor :has_config

    BUFFER_HEADER_SIZE = 12
    ARRAY_BUFFER_CLASS_ID = 1
    STRING_CLASS_ID = 2
    HEADER_ID = 9

    @@rand = Random.new(seed = Random.new_seed)
    @@engine = Wasmtime::Engine.new(parallel_compilation: false) 
    # added to ensure that there is no processes deadlock when compiling wasm before forking

    @@wasmmodule = Wasmtime::Module.from_file(@@engine, "#{__dir__}/bucketing-lib.release.wasm")
    @@wasi_ctx = Wasmtime::WasiCtxBuilder.new
                                         .inherit_stdout
                                         .inherit_stderr
                                         .set_argv(ARGV)
                                         .set_env(ENV)
                                         .build
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

    @@stack_tracer_raise = lambda { |message| raise message }
    # each method reassigns stack_tracer so the call stack is properly displayed
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
      options: Options,
      wait_for_init: T::Boolean
    ).void }
    def initialize(sdkkey, options, wait_for_init)
      @initialized = false
      @has_config = false
      @sdkkey = sdkkey
      @options = options
      @logger = options.logger
      @wasm_mutex = Mutex.new
      @variable_type_codes = {
        boolean: @@instance.export("VariableType.Boolean").to_global.get.to_i,
        string: @@instance.export("VariableType.String").to_global.get.to_i,
        number: @@instance.export("VariableType.Number").to_global.get.to_i,
        json: @@instance.export("VariableType.JSON").to_global.get.to_i
      }
      @buffer_header_addr = @@instance.export("__new").to_func.call(BUFFER_HEADER_SIZE, HEADER_ID)
      asc_pin(@buffer_header_addr)
      set_sdk_key_internal(sdkkey)
      platform_data = PlatformData.new('server', VERSION, RUBY_VERSION, nil, 'Ruby', Socket.gethostname)
      set_platform_data(platform_data)
      @config_manager = ConfigManager.new(@sdkkey, self, wait_for_init)
    end

    def close
      @config_manager.close
      @config_manager = nil
    end

    sig { params(user: User).returns(BucketedUserConfig) }
    def generate_bucketed_config(user)
      @wasm_mutex.synchronize do
        user_addr = malloc_asc_byte_array(user.to_json)
        @@stack_tracer = @@stack_tracer_raise
        config_addr = @@instance.invoke("generateBucketedConfigForUserUTF8", @sdkKeyAddr, user_addr)
        bucketed_config_json = read_asc_byte_array(config_addr)
        bucketed_config_hash = Oj.load(bucketed_config_json)

        BucketedUserConfig.new(bucketed_config_hash['project'],
                              bucketed_config_hash['environment'],
                              bucketed_config_hash['features'],
                              bucketed_config_hash['featureVariationMap'],
                              bucketed_config_hash['variableVariationMap'],
                              bucketed_config_hash['variables'],
                              bucketed_config_hash['knownVariableKeys'])
      end
    end

    sig { params(user: User, key: String, variable_type: Integer).returns(T.nilable(String)) }
    def variable_for_user(user, key, variable_type)
      @wasm_mutex.synchronize do
        user_addr = malloc_asc_string(user.to_json)
        key_addr = malloc_asc_string(key)
        @@stack_tracer = @@stack_tracer_raise
        var_addr = @@instance.invoke("variableForUser", @sdkKeyAddr, user_addr, key_addr, variable_type, 1)
        read_asc_string(var_addr)
      end
    end

    sig { params(bin_str: String).returns(T.nilable(String)) }
    def variable_for_user_pb(bin_str)
      @wasm_mutex.synchronize do
        @@stack_tracer = @@stack_tracer_raise
        params_addr = malloc_asc_byte_array(bin_str)
        var_addr = @@instance.invoke("variableForUser_PB", params_addr)
        read_asc_byte_array(var_addr)
      end
    end

    sig { returns(T::Array[EventsPayload]) }
    def flush_event_queue
      @wasm_mutex.synchronize do
        @@stack_tracer = @@stack_tracer_raise
        payload_addr = @@instance.invoke("flushEventQueue", @sdkKeyAddr)
        raw_json = read_asc_string(payload_addr)
        raw_payloads = Oj.load(raw_json)

        if raw_payloads == nil
          return []
        end
        raw_payloads.map { |raw_payload| EventsPayload.new(raw_payload["records"], raw_payload["payloadId"], raw_payload["eventCount"]) }
      end
    end

    sig { returns(Integer) }
    def check_event_queue_size
      @wasm_mutex.synchronize do
        @@stack_tracer = @@stack_tracer_raise
        @@instance.invoke("eventQueueSize", @sdkKeyAddr)
      end
    end

    sig { params(payload_id: String).returns(NilClass) }
    def on_payload_success(payload_id)
      @wasm_mutex.synchronize do
        payload_addr = malloc_asc_string(payload_id)
        @@stack_tracer = @@stack_tracer_raise
        @@instance.invoke("onPayloadSuccess", @sdkKeyAddr, payload_addr)
      end
    end

    sig { params(payload_id: String, retryable: Object).returns(NilClass) }
    def on_payload_failure(payload_id, retryable)
      @wasm_mutex.synchronize do
        payload_addr = malloc_asc_string(payload_id)
        @@stack_tracer = @@stack_tracer_raise
        @@instance.invoke("onPayloadFailure", @sdkKeyAddr, payload_addr, retryable ? 1 : 0)
      end
    end

    sig { params(user: User, event: Event).returns(NilClass) }
    def queue_event(user, event)
      @wasm_mutex.synchronize do
        begin
          user_addr = malloc_asc_string(user.to_json)
          asc_pin(user_addr)
          event_addr = malloc_asc_string(event.to_json)
          @@stack_tracer = @@stack_tracer_raise
          @@instance.invoke("queueEvent", @sdkKeyAddr, user_addr, event_addr)
        ensure
          asc_unpin(user_addr)
        end
      end
    end

    sig { params(event: Event, bucketeduser: T.nilable(BucketedUserConfig)).returns(NilClass) }
    def queue_aggregate_event(event, bucketeduser)
      @wasm_mutex.synchronize do
        begin
          variable_variation_map =
            if !bucketeduser.nil?
              bucketeduser.variable_variation_map
            else
              {}
            end
          varmap_addr = malloc_asc_string(Oj.dump(variable_variation_map))
          asc_pin(varmap_addr)
          event_addr = malloc_asc_string(event.to_json)
          @@stack_tracer = @@stack_tracer_raise
          @@instance.invoke("queueAggregateEvent", @sdkKeyAddr, event_addr, varmap_addr)
        ensure
          asc_unpin(varmap_addr)
        end
      end
    end

    sig { params(config: String).returns(NilClass) }
    def store_config(config)
      @wasm_mutex.synchronize do
        config_addr = malloc_asc_byte_array(config)
        @@stack_tracer = @@stack_tracer_raise
        @@instance.invoke("setConfigDataUTF8", @sdkKeyAddr, config_addr)
      end
    end

    sig { params(client_uuid: String, options: EventQueueOptions).returns(NilClass) }
    def init_event_queue(client_uuid, options)
      @wasm_mutex.synchronize do
        options_json = Oj.dump(options)
        client_uuid_addr = malloc_asc_string(client_uuid)
        options_addr = malloc_asc_string(options_json)
        @@stack_tracer = @@stack_tracer_raise
        @@instance.invoke("initEventQueue", @sdkKeyAddr, client_uuid_addr, options_addr)
      end
    end

    sig { params(custom_data: Hash).returns(NilClass) }
    def set_client_custom_data(custom_data)
      @wasm_mutex.synchronize do
        custom_data_json = Oj.dump(custom_data, mode: :json)
        custom_data_addr = malloc_asc_byte_array(custom_data_json)
        @@stack_tracer = @@stack_tracer_raise
        @@instance.invoke("setClientCustomDataUTF8", @sdkKeyAddr, custom_data_addr)
      end
    end

    private

    sig { params(platform_data: PlatformData).returns(NilClass) }
    def set_platform_data(platform_data)
      @wasm_mutex.synchronize do
        platform_data_json = platform_data.to_json
        platform_data_addr = malloc_asc_byte_array(platform_data_json)
        @@stack_tracer = @@stack_tracer_raise
        @@instance.invoke("setPlatformDataUTF8", platform_data_addr)
      end
    end

    def set_sdk_key_internal(sdkKey)
      @wasm_mutex.synchronize do
        addr = malloc_asc_string(sdkKey)
        @sdkKeyAddr = addr
        asc_pin(addr)
      end
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
      @@stack_tracer = @@stack_tracer_raise
      wasm_new = @@instance.export("__new").to_func
      utf8_bytes = string.bytes
      byte_len = utf8_bytes.length

      start_addr = wasm_new.call(byte_len * 2, STRING_CLASS_ID)
      i = 0
      while i < byte_len
        @@stack_tracer = @@stack_tracer_raise
        @@memory.write(start_addr + (i * 2), [utf8_bytes[i]].pack('c'))
        i += 1
      end
      start_addr
    end

    # @param [Integer] address start address of string.
    # @return [String] resulting string
    sig { params(address: Integer).returns(T.nilable(String)) }
    def read_asc_string(address)
      if address == 0
        @logger.debug("null address passed to read_asc_string")
        return nil
      end

      @@stack_tracer = @@stack_tracer_raise
      raw_bytes = @@memory.read(address - 4, 4).bytes
      len = asc_bytes_to_int(raw_bytes)

      @@stack_tracer = @@stack_tracer_raise
      result = @@memory.read(address, len).bytes
      result.select.with_index { |_, i| i.even? }.pack('c*')
    end

    # @param [String] string utf8 string to allocate
    # @return [Integer] address to WASM String
    sig { params(raw_str: String).returns(Integer) }
    def malloc_asc_byte_array(raw_str)
      align = 0
      @@stack_tracer = @@stack_tracer_raise
      wasm_new = @@instance.export("__new").to_func

      # break up the UTF-8 characters in raw_str into bytes and pack them into a binary sequence
      # example: "Ϗ" -> "\xCF\x8F"
      bin_string = raw_str.bytes.pack('C*')
      length = bin_string.length

      # allocate buffer of size length - returned address is in Big Endian order
      buffer_addr = wasm_new.call(length << align, ARRAY_BUFFER_CLASS_ID)

      # convert to array of bytes in Little Endian order
      # - pack('L<') packs the address into a binary sequence in Little Endian order
      # - unpack('C*') converts each byte in the string to it's decimal representation
      buffer_addr_little_endian_bytes = [buffer_addr].pack('L<').unpack('C*')

      # write address byte values in Little Endian order to header
      buffer_addr_little_endian_bytes.each_with_index { |byte, i|
        @@memory.write(@buffer_header_addr + i, [byte].pack('C'))
        @@memory.write(@buffer_header_addr + i + 4, [byte].pack('C'))
      }

      # convert length to an array of bytes in Little Endian order
      byte_len_little_endian_bytes = [length].pack('L<').unpack('C*')

      # write length to header
      byte_len_little_endian_bytes.each_with_index { |byte, i|
        @@memory.write(@buffer_header_addr + i + 8, [byte].pack('C'))
      }

      # write data bytes to buffer
      bin_string.each_char.with_index { |char, i|
        @@memory.write(buffer_addr + i, char)
      }

      @buffer_header_addr
    end

    sig { params(address: Integer).returns(T.nilable(String)) }
    def read_asc_byte_array(address)
      if address == 0
        @logger.debug("null address passed to read_asc_byte_array")
        return nil
      end

      length_bytes = @@memory.read(address + 8, 4).bytes
      length = asc_bytes_to_int(length_bytes)

      buffer_addr_bytes = @@memory.read(address, 4).bytes
      buffer_addr = asc_bytes_to_int(buffer_addr_bytes)

      @@memory.read(buffer_addr, length)
    end

    # @param [Array<Integer>] bytes: array of bytes in Little Endian order
    # @return [Integer] integer value
    # @example
    #  asc_bytes_to_int([0, 4, 0, 0]) # => 1024 = (0 << 0) + (4 << 8) + (0 << 16) + (0 << 24)
    sig { params(bytes: T::Array[Integer]).returns(Integer) }
    def asc_bytes_to_int(bytes)
      bytes.each_with_index.reduce(0) { |acc, (byte, i)|
        acc + (byte << (i * 8))
      }
    end
  end
end
