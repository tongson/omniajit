local ffi = require "ffi"
ffi.cdef [[
const char *clean(const char *h);
const char *clean_text(const char *h);
]]

local p = package.ffipath
if package.ffipath == "/" then
    p = "./"
end   

M = ffi.load(p.."libammonia_c.so")

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
