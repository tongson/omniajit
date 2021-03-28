local ffi = require 'ffi'
ffi.cdef [[
int del(const char *, const char *);
int incr(const char *, const char *);
int json_get(const char *, const char *, unsigned char *);
int get(const char *, const char *, unsigned char *);
int json_set(const char *, const char *);
int set(const char *, const char *);
int hset(const char *, const char *);
int hget(const char *, const char *, unsigned char *);
]]
local M = ffi.load(arg.path.ffi..'/libljredis.so.0.1.0')
local F = string.format
local J = require 'json'
local B = require 'base64'

local LOCALHOST = '127.0.0.1'
local ECONN = -13
local ECLIENT = -43
local EINVALID = -9
local EQUERY = -4
local OK = 0
local MAX = 536870912

local E = function(n, r)
  local rt = {
    [ECONN]    = F('redis.%s: Unable to establish connection with Redis.', n),
    [ECLIENT]  = F('redis.%s: Failure preparing Redis client.', n),
    [EQUERY]   = F('redis.%s: Problem with the Redis query.', n),
    [EINVALID] = F('redis.%s: Invalid JSON.', n),
  }
  return rt[r] or F('redis.%s: Invalid return value.', n)
end

return {
  del = function(k, h)
    h = h or LOCALHOST
    local r = M.del(h, k)
    if r == OK then
      return true
    else
      return nil, E('del', r)
    end
  end,
  incr = function(k, h)
    h = h or LOCALHOST
    local r = M.incr(h, k)
    if r == OK then
      return true
    else
      return nil, E('incr', r)
    end
  end,
  json_get = function(k, h)
    h = h or LOCALHOST
    local b = ffi.new('unsigned char[?]', MAX)
    local r = M.json_get(h, J.encode(k), b)
    if r > 0 then
      return J.decode(ffi.string(b, r))
    else
      return nil, E('json_get', r)
    end
  end,
  get = function(k, h)
    h = h or LOCALHOST
    local b = ffi.new('unsigned char[?]', MAX)
    local r = M.get(h, k, b)
    if r > 0 then
      return ffi.string(b, r)
    else
      return nil, E('get', r)
    end
  end,
  json_set = function(t, h)
    h = h or LOCALHOST
    if not t.nx then
      t.nx = "false"
    else
      t.nx = "true"
    end
    t.data = B.encode(J.encode(t.data))
    local r = M.json_set(h, J.encode(t))
    if r == OK then
      return true
    else
      return nil, E('json_set', r)
    end
  end,
  set = function(t, h)
    h = h or LOCALHOST
    if not t.expire then
      t.expire = "0"
    else
      t.expire = tostring(t.expire)
    end
    local r = M.set(h, J.encode(t))
    if r == OK then
      return true
    else
      return nil, E('set', r)
    end
  end,
  hset = function(t, h)
    h = h or LOCALHOST
    local r = M.hset(h, J.encode(t))
    if r == OK then
      return true
    else
      return nil, E('hset', r)
    end
  end,
  hget = function(t, h)
    h = h or LOCALHOST
    local b = ffi.new('unsigned char[?]', MAX)
    local r = M.hget(h, J.encode(t), b)
    if r > 0 then
      return ffi.string(b, r)
    else
      return nil, E('hget', r)
    end
  end,
}
