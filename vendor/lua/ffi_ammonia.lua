local ffi = require "ffi"
ffi.cdef [[
const char *clean(const char *h);
const char *clean_text(const char *h);
]]

local p = package.cpath
if package.cpath == "/" then
    p = "./"
end   

M = ffi.load(p.."libammonia_c.so")

return {
    clean = function (s) return ffi.string(M.clean(s)) end,
    clean_text = function (s) return ffi.string(M.clean_text(s)) end,
}
