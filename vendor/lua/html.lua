local ffi = require 'ffi'
ffi.cdef [[
const char *clean(const char *);
const char *clean_text(const char *);
]]

local p = package.__ffi or '.'
local M = ffi.load(p..'/libhtml.so')
local T = require 'lhutil'
-- These are HTML strings so just ignore 8-bit clean strings.
T.clean = function (s)
  return ffi.string(M.clean(s))
end
T.clean_text = function (s)
  return ffi.string(M.clean_text(s))
end
return T
