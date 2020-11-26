local ffi = require "ffi"
ffi.cdef [[
const char *base64(const char *h);
const char *hash(const char *h);
]]

local p = package.ffipath
if p == nil then
  return nil, "package.ffipath not set."
if p == "/" then
  p = "."
end

local M = ffi.load(p.."/libblake3_c.so")

return {
    base64 = function (s)
        if not s then
            return nil, "Missing argument."
        end
        return ffi.string(M.base64(s))
    end,
    hash = function (s)
        if not s then
            return nil, "Missing argument."
        end
        return ffi.string(M.hash(s))
    end,
}
