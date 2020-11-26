local ffi = require "ffi"
ffi.cdef [[
const char *clean(const char *h);
const char *clean_text(const char *h);
]]

local p = package.ffipath
if p == nil then
  return nil, "package.ffipath not set."
if p == "/" then
  p = "."
end

local M = ffi.load(p.."/libammonia_c.so")

return {
    clean = function (s)
        if not s then
            return nil, "Missing argument."
        end
        return ffi.string(M.clean(s))
    end,
    clean_text = function (s)
        if not s then
            return nil, "Missing argument."
        end
        return ffi.string(M.clean_text(s))
    end,
}
