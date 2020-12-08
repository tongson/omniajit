local ffi = require "ffi"
ffi.cdef [[
const char *clean(const char *);
const char *clean_text(const char *);
]]

local p = package.ffipath
if p == nil then
  return nil, "package.ffipath not set."
elseif p == "/" then
  p = "."
end

local M = ffi.load(p.."/libammonia_c.so")

return {
    clean = function (s)
        return ffi.string(M.clean(s))
    end,
    clean_text = function (s)
        return ffi.string(M.clean_text(s))
    end,
}
