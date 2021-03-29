local ffi = require 'ffi'
ffi.cdef [[
int *hash(unsigned char*, size_t, unsigned char*);
]]
local M = ffi.load(arg.path.ffi.."/libblake.so.a3e0958")
return {
  hash = function (s)
    local b = ffi.new("unsigned char[?]", 64)
    local l = #s
    local p = ffi.new("unsigned char[?]", l)
    ffi.copy(p, s, l)
    M.hash(p, l, b)
    return ffi.string(b, 64)
  end,
}
