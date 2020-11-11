local ffi = require "ffi"
ffi.cdef [[
const char *clean(const char *h);
const char *clean_text(const char *h);
]]

mod = ffi.load("libammonia_c.so")

return {
    clean = function (s) return ffi.string(mod.clean(s)) end,
    clean_text = function (s) return ffi.string(mod.clean_text(s)) end,
}
