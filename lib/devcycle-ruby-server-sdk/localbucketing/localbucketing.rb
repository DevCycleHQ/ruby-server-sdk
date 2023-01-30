require "wasmtime"

module DevCycle
  class LocalBucketing
    @engine = Wasmtime::Engine.new
    @wasmmodule = Wasmtime::Module.from_file(engine, "sourceWasm")
    @store = Wasmtime::Store.new(engine)
    @instance = Wasmtime::Instance.new(store, @wasmmodule)
    @memory = instance.export("memory").to_memory

    def initialize

    end

    # @param [String] string utf8 string to allocate
    # @return [Integer] address to WASM String
    def self.malloc_wasm_string(string)
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
    def self.read_wasm_string(address)
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
end
