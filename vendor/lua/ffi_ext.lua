local ffi = require "ffi"
local C = ffi.C
local ffiext = {}
ffi.cdef[[
static const int EINTR = 4; /* Linux: Interrupted system call */
static const int EAGAIN = 11; /* Linux: Try again */
static const int GRND_NONBLOCK = 1;
char *strerror(int);
int dprintf(int, const char *, ...);
ssize_t getrandom(void *, size_t, unsigned int);
]]
ffiext.dprintf = function(fd, s, ...)
  s = string.format(s, ...)
  local len = string.len(s)
  local str = ffi.new("char[?]", len + 1)
  ffi.copy(str, s, len)
  C.dprintf(fd, str)
end
ffiext.strerror = function(e, s)
  s = s or "error"
  return string.format("%s: %s\n", s, ffi.string(C.strerror(e)))
end
ffiext.retry = function(fn)
  return function(...)
    local r, e
    repeat
      r = tonumber(fn(...))
      e = ffi.errno()
      if (r ~= -1) or ((r == -1) and (e ~= C.EINTR) and (e ~= C.EAGAIN)) then
        break
      end
    until((e ~= C.EINTR) and (e ~= C.EAGAIN))
    return r, e
  end
end
ffiext.open = function(filename)
  local octal = function(n) return tonumber(n, 8) end
  local O_WRONLY = octal('0001')
  local O_CREAT  = octal('0100')
  local S_IRUSR  = octal('00400') -- user has read permission
  local S_IWUSR  = octal('00200') -- user has write permission
  local r, e = ffiext.retry(C.open)(filename, bit.bor(O_WRONLY, O_CREAT), bit.bor(S_IRUSR, S_IWUSR))
  if r > 0 then
    return r
  else
    return -1, e
  end
end
ffiext.getrandom = function(s)
  s = s or 512
  local buf = ffi.new(ffi.typeof("char[?]"), s)
  local r, e = ffiext.retry(C.getrandom)(buf, s, bit.bor(C.GRND_NONBLOCK))
  if r ~= s then
    return nil, "Not enough returned bytes."
  end
  return ffi.string(buf)
end
return ffiext
