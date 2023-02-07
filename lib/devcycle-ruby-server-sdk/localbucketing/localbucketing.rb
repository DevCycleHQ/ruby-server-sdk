require 'wasmtime'
require 'date'
require 'bigdecimal'
# Temp commenting out the module for testing within the file raw.
# module DevCycle
class LocalBucketing

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
    # Return an array with 2 elements for 2 results
    Time.now.to_f
  end

  @@linker.func_new("env", "abort", [:i32, :i32, :i32, :i32], []) do |_caller, messagePtr, filenamePtr, lineNum, colNum|

    exceptionMessage = ""
    exceptionFilename = ""

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
        exceptionMessage = result
      else
        if m == filenamePtr
          exceptionFilename = result
        end
      end
    }

    STDERR.puts("WASM Exception: #{exceptionMessage} - #{exceptionFilename} #{lineNum}:#{colNum}")
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
    @@rand.rand(1.0) * Time.now.to_f
  end

  @@instance = @@linker.instantiate(@@store, @@wasmmodule)
  @@memory = @@instance.export("memory").to_memory

  def initialize(sdkkey, options)
    @sdkkey = sdkkey
    @options = options

    # Set Platform Data
    # Initialize the Event Queue
    # Initialize Config Polling
    set_platform_data('{"sdkType": "server", "sdkVersion":"testing","platformVersion":"1.0.0","platform":"Ruby", "hostname":"localhost"}')
    puts('Set platformdata')
    store_config(sdkkey, '{"project":{"settings":{"edgeDB":{"enabled":false},"optIn":{"enabled":true,"title":"Beta Feature Access","description":"Get early access to new features below","imageURL":"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR68cgQT_BTgnhWTdfjUXSN8zM9Vpxgq82dhw&usqp=CAU","colors":{"primary":"#0042f9","secondary":"#facc15"}}},"a0_organization":"org_NszUFyWBFy7cr95J","_id":"6216420c2ea68943c8833c09","key":"default"},"environment":{"_id":"6216420c2ea68943c8833c0b","key":"development"},"features":[{"_id":"6216422850294da359385e8b","key":"test","type":"release","variations":[{"variables":[{"_var":"6216422850294da359385e8d","value":true}],"name":"Variation On","key":"variation-on","_id":"6216422850294da359385e8f"},{"variables":[{"_var":"6216422850294da359385e8d","value":false}],"name":"Variation Off","key":"variation-off","_id":"6216422850294da359385e90"}],"configuration":{"_id":"621642332ea68943c8833c4a","targets":[{"distribution":[{"percentage":0.5,"_variation":"6216422850294da359385e8f"},{"percentage":0.5,"_variation":"6216422850294da359385e90"}],"_audience":{"_id":"621642332ea68943c8833c4b","filters":{"operator":"and","filters":[{"values":[],"type":"all","filters":[]}]}},"_id":"621642332ea68943c8833c4d"}],"forcedUsers":{}}}],"variables":[{"_id":"6216422850294da359385e8d","key":"test","type":"Boolean"}],"variableHashes":{"test":2447239932}}')
    puts('Set config')
    init_event_queue('{"flushEventsMS":1000,"disableAutomaticEventLogging":false,"disableCustomEventLogging":false}')
  end

  def generate_bucketed_config(user)
    sdkkey_addr = malloc_wasm_string(@sdkkey)
    user_addr = malloc_wasm_string(user)
    config_addr = @@instance.invoke("generateBucketedConfigForUser", sdkkey_addr, user_addr)
    read_wasm_string(config_addr)
  end

  def store_config(sdkkey, config)
    sdkkey_addr = malloc_wasm_string(sdkkey)
    config_addr = malloc_wasm_string(config)
    @@instance.invoke("setConfigData", sdkkey_addr, config_addr)
  end

  def set_platform_data(platformdata)
    platformdata_addr = malloc_wasm_string(platformdata)
    @@instance.invoke("setPlatformData", platformdata_addr)
  end

  def init_event_queue(options)
    sdkkey_addr = malloc_wasm_string(@sdkkey)
    options_addr = malloc_wasm_string(options.to_s)
    @@instance.invoke("initEventQueue", sdkkey_addr, options_addr)
  end

  def flush_event_queue
    sdkkey_addr = malloc_wasm_string(@sdkkey)
    payload_addr = @@instance.invoke("flushEventQueue", sdkkey_addr)
    payload = read_wasm_string(payload_addr)
  end

  def check_event_queue_size
    sdkkey_addr = malloc_wasm_string(@sdkkey)
    size = @@instance.invoke("eventQueueSize", sdkkey_addr)
    size
  end

  def on_payload_success(payload_id)
    sdkkey_addr = malloc_wasm_string(@sdkkey)
    payload_addr = malloc_wasm_string(payload_id)
    @@instance.invoke("onPayloadSuccess", sdkkey_addr, payload_addr)
  end

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

  def on_payload_failure(payload_id, retryable)
    sdkkey_addr = malloc_wasm_string(@sdkkey)
    payload_addr = malloc_wasm_string(payload_id)
    @@instance.invoke("onPayloadFailure", sdkkey_addr, payload_addr, retryable ? 1 : 0)
  end

  private

  # @param [String] string utf8 string to allocate
  # @return [Integer] address to WASM String
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

# end
# test_config = `{"project":{"settings":{"edgeDB":{"enabled":false},"optIn":{"enabled":true,"title":"Beta Feature Access","description":"Get early access to new features below","imageURL":"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR68cgQT_BTgnhWTdfjUXSN8zM9Vpxgq82dhw&usqp=CAU","colors":{"primary":"#0042f9","secondary":"#facc15"}}},"a0_organization":"org_NszUFyWBFy7cr95J","_id":"6216420c2ea68943c8833c09","key":"default"},"environment":{"_id":"6216420c2ea68943c8833c0b","key":"development"},"features":[{"_id":"6216422850294da359385e8b","key":"test","type":"release","variations":[{"variables":[{"_var":"6216422850294da359385e8d","value":true}],"name":"Variation On","key":"variation-on","_id":"6216422850294da359385e8f"},{"variables":[{"_var":"6216422850294da359385e8d","value":false}],"name":"Variation Off","key":"variation-off","_id":"6216422850294da359385e90"}],"configuration":{"_id":"621642332ea68943c8833c4a","targets":[{"distribution":[{"percentage":0.5,"_variation":"6216422850294da359385e8f"},{"percentage":0.5,"_variation":"6216422850294da359385e90"}],"_audience":{"_id":"621642332ea68943c8833c4b","filters":{"operator":"and","filters":[{"values":[],"type":"all","filters":[]}]}},"_id":"621642332ea68943c8833c4d"}],"forcedUsers":{}}}],"variables":[{"_id":"6216422850294da359385e8d","key":"test","type":"Boolean"}],"variableHashes":{"test":2447239932}}`
localbucketing = LocalBucketing.new("dvc_server_token_hash", {})

puts("config?")
puts(localbucketing.generate_bucketed_config('{"user_id":"test"}'))
puts("event queue size")
puts(localbucketing.check_event_queue_size)