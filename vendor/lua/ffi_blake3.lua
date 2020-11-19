local ffi = require "ffi"
ffi.cdef [[
const char *hash(const char *h);
const char *hex(const char *h);
]]

local p = package.ffipath
if package.ffipath == "/" then
    p = "./"
end   

M = ffi.load(p.."libblake3_c.so")

return {
    hash = function (s)
        if not s then
            return nil, "Missing argument."
        end
        return ffi.string(M.hash(s))
    end,
    hex = function (s)
        if not s then
            return nil, "Missing argument."
        end
        return ffi.string(M.hex(s))
    end,
}
