local ffi = require 'ffi'
ffi.cdef [[
int *hash(const char *, unsigned char*, size_t);
]]

local B = require 'base64'
local M = ffi.load(arg.path.ffi.."/libblake.so.a3e0958")

return {
  hash = function (s)
    local b = ffi.new("unsigned char[?]", 64)
    M.hash(B.encode(s), b, 64)
    return ffi.string(b, 64)
  end,
}
