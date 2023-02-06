require "wasmtime"
require "date"

# Temp commenting out the module for testing within the file raw.
# module DevCycle
class LocalBucketing
  @@rand = Random.new(seed = Random.new_seed)
  @@engine = Wasmtime::Engine.new
  @@wasmmodule = Wasmtime::Module.from_file(engine, "bucketing-lib.release.wasm")
  @@store = Wasmtime::Store.new(engine)
  @@linker = Wasmtime::Linker.new(@@engine, wasi: true)

  @@linker.func_new("env", "Date.now", [], [:i64]) do |_caller|
    # Return an array with 2 elements for 2 results
    Time.now.to_f.to_i
  end

  @@linker.func_new("env", "abort", [:i32, :i32, :i32, :i32], []) do |_caller, messagePtr, filenamePtr, lineNum, colNum|
    message = self.read_wasm_string(messagePtr)
    filename = self.read_wasm_string(filenamePtr)
    STDERR.puts("WASM Exception: #{message}@#{filename} #{lineNum}:#{colNum}")
    exit(100)
  end

  @@linker.func_new("env", "console.log", [:i32], []) do |_caller, messagePtr|
    message = self.read_wasm_string(messagePtr)
    STDOUT.puts(message)
  end

  @@linker.func_new("env", "seed", [], [:i64]) do |_caller|
    (@@rand.rand(1.0) * Time.now.to_f.to_i).to_i
  end

  @@instance = @@linker.instantiate(@@store, @@wasmmodule)
  @@memory = @@instance.export("memory").to_memory

  def initialize(sdkkey, options)
    @sdkkey = sdkkey
    @options = options
  end

  def generate_bucketed_config(user)
    sdkkey_addr = malloc_wasm_string(@sdkkey)
    user_addr = malloc_wasm_string(user.to_s)
    instance.invoke("generateBucketedConfigForUser", sdkkey_addr, user_addr)
  end

  def store_config(sdkkey, config) end

  def set_platform_data(platformdata)

  end

  private

  def init_event_queue(options)
  end

  def flush_event_queue() end

  def check_event_queue_size

  end

  def on_payload_success(payload_id)
    payload_id
  end

  def queue_event(user, event) end

  def queue_aggregate_event(event, bucketeduser) end

  def on_payload_failure(payload_id)
    payload_id
  end

  # @param [String] string utf8 string to allocate
  # @return [Integer] address to WASM String
  def malloc_wasm_string(string)
    wasm_object_id = 1
    wasm_new = @instance.export("__new").to_func
    utf8_bytes = string.encode("iso-8859-1").force_encoding("utf-8").bytes
    byte_len = utf8_bytes.bytesize

    start_addr = wasm_new.call(byte_len * 2, wasm_object_id)
    i = 0
    while i < byte_len
      @memory.write(start_addr + (i * 2), utf8_bytes[i])
      i += 1
    end

    start_addr
  end

  # @param [Integer] address start address of string.
  # @return [String] resulting string
  def read_wasm_string(address)
    length = @memory.read(address - 4, 4).unpack("N").first
    result = ""
    i = 0
    while i < length
      result += @memory.read(address + i)
      i += 2
    end
    result
  end
end

# end

localbucketing = new.LocalBucketing("sdkkey", {})
