local ffi = require 'ffi'
local json = require 'json'
ffi.cdef [[
unsigned int score(const char *h);
]]

local p = arg.path.ffi or '.'
local M = ffi.load(p..'/libpasswdqc.so')

return {
  score = function (t)
    local s = M.score(json.encode(t))
    -- <3 bad, 5 error
    if s == 3 or s == 4 then
      return true
    else
      return false
    end
 end
}
