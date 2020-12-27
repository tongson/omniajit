local F = string.format
local Hmac = require 'hmac'
local Time = require 'std'.time
local ffi = require 'ffi'
ffi.cdef [[
const char *clean(const char *);
const char *clean_text(const char *);
]]

local p = arg.path.ffi or '.'
local M = ffi.load(p..'/libhtml.so')
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
T.get_domain = function(str)
  return string.match(str, '[^%.]+%.(.*)')
end
T.authelia_logout = function(domain)
  return "https://"..arg.settings.authelia_subdomain.."."..domain.."/logout"
end
return T
