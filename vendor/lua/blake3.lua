local ffi = require "ffi"
ffi.cdef [[
const char *base64(const char *);
const char *hash(const char *);
]]

local p = package.ffipath
if p == nil then
  return nil, "package.ffipath not set."
elseif p == "/" then
  p = "."
end

local M = ffi.load(p.."/libblake3_c.so")

return {
    base64 = function (s)
        return ffi.string(M.base64(s))
    end,
    hash = function (s)
        return ffi.string(M.hash(s))
    end,
}
