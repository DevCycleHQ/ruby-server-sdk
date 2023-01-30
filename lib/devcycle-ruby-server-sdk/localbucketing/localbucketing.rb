require "wasmtime"

module DevCycle
  class LocalBucketing
    @engine = Wasmtime::Engine.new
    @wasmmodule = Wasmtime::Module.from_file(engine, "sourceWasm")
    @store = Wasmtime::Store.new(engine)
    @instance = Wasmtime::Instance.new(store, wasmmodule)
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

    def self.read_wasm_string(address)
      length = @memory.read(address - 4, 4).unpack("N").first
      result = ""
      i = 0
      while i < length
        result += @memory.read(address + i)
        i += 2
      end
    end
  end
end
#     private String readWasmString(int startAddress) {
#         ByteBuffer buf = memRef.get().buffer(store);
#
#         // objects in wasm memory have a 20 byte header before the start pointer
#         // the 4 bytes right before the object pointer store the length of the object as an unsigned int
#         // see assemblyscript.org/runtime.html#memory-layout
#         byte[] headerBytes = {buf.get(startAddress - 1), buf.get(startAddress - 2), buf.get(startAddress - 3), buf.get(startAddress - 4)};
#         long stringLength = getUnsignedInt(headerBytes);
#         String result = "";
#         for (int i = 0; i < stringLength; i += 2) { // +=2 because the data is formatted as WTF-16, not UTF-8
#             result += (char) buf.get(startAddress + i); // read each byte of string starting at address
#         }
#
#         return result;
#     }