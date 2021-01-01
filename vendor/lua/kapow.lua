local ffi = require 'ffi'
ffi.cdef [[
const char *get(const char *);
const char *b64_get(const char *);
const char *set(const char *);
]]

local ACK = string.char(6)
local NAK = string.char(21)
local base64 = require 'base64'
local json = require 'json'
local M = ffi.load(arg.path.ffi.."/libfastkapow.so")

local set = function (t)
  local r = ffi.string(M.set(json.encode(t)))
  if r == ACK then
    return true
  else
    return nil, 'fastkapow.set: Error in fetching data or missing ENV variables.'
  end
end

return {
  qget = function (s)
    local r = ffi.string(M.get(s))
    if not (r == NAK) then
      return r
    else
      return nil, 'fastkapow.qget: Error in fetching data or missing ENV variables.'
    end
  end,
  get = function (s)
    local r = ffi.string(M.b64_get(s))
    if not (r == NAK) then
      return base64.decode(r)
    else
      return nil, 'fastkapow.get: Error in fetching data or missing ENV variables.'
    end
  end,
  set = set,
  ok = function (s)
    do
      local r, e = set { resource = '/response/status', data = '200'}
      if not r then
        return nil, e
      end
    end
    do
      local r, e = set { resource = '/response/body', data = s }
      if not r then
        return nil, e
      end
    end
  end,
  redirect = function (u)
    do
      local r, e = set { resource = '/response/status', data = '303' }
      if not r then
        return nil, e
      end
    end
    do
      local r, e = set { resource = '/response/headers/Location', data = u }
      if not r then
        return nil, e
      end
    end
  end,
}
