local ffi = require 'ffi'
ffi.cdef [[
const char *hash(const char *);
]]

local B = require 'base64'
local M = ffi.load(arg.path.ffi.."/libblake.so")

return {
  hash = function (s)
    return ffi.string(M.hash(B.encode(s)))
  end,
}
