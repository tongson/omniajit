local F = string.format
local Hmac = require 'hmac'
local Time = require 'std'.time
local ffi = require 'ffi'
ffi.cdef [[
const char *clean(const char *);
const char *clean_text(const char *);
]]

local M = ffi.load(arg.path.ffi..'/libhtml.so.5eea2c1')
local T = require 'lhutil'
-- These are HTML strings so just ignore 8-bit clean strings.
T.clean = function (s)
  return ffi.string(M.clean(s))
end
T.clean_text = function (s)
  return ffi.string(M.clean_text(s))
end
T.form_token = function (i, u)
  local m = F([[%s..%s..%s]], i, Time.ymd(), u)
  return Hmac.compute(arg.settings.secret, m)
end
T.split_host = function(str)
  return string.match(str, '([^%.]+)%.(.*)')
end
T.authelia_logout = function(sub, host)
  local _, domain  = T.split_host(host)
  return "https://"..sub.."."..domain.."/logout"
end
return T
