local ffi = require 'ffi'
ffi.cdef [[
int del(const char *, const char *);
int incr(const char *, const char *);
int get(const char *, const char *, unsigned char *);
int set(const char *, const char *);
int hset(const char *, const char *);
int hsetnx(const char *, const char *);
int hget(const char *, const char *, unsigned char *);
int hdel(const char *, const char *);
]]
local M = ffi.load(arg.path.ffi..'/libljredis.so.0.1.0')
local F = string.format
local J = require 'json'

local LOCALHOST = '127.0.0.1'
local ECONN = -13
local ECLIENT = -43
local EINVALID = -9
local EQUERY = -4
local EMAX = -11
local OK = 0
local MAX = 536870912

local E = function(n, r)
  local rt = {
    [ECONN]    = F('redis.%s: Unable to establish connection with Redis.', n),
    [ECLIENT]  = F('redis.%s: Failure preparing Redis client.', n),
    [EQUERY]   = F('redis.%s: Problem with the Redis query.', n),
    [EINVALID] = F('redis.%s: Invalid JSON.', n),
    [EMAX]     = F('redis.%s: Value exceeds 512MB.', n),
  }
  return rt[r] or F('redis.%s: Invalid return value.', n)
end

return {
  del = function(k, h)
    h = h or LOCALHOST
    local r = M.del(h, k)
    if r == 1 then
      return true
    elseif r == 0 then
      return false
    else
      return nil, E('del', r)
    end
  end,
  incr = function(k, h)
    h = h or LOCALHOST
    local r = M.incr(h, k)
    if r >= 0 then
      return r
    else
      return nil, E('incr', r)
    end
  end,
  get = function(k, h)
    h = h or LOCALHOST
    local b = ffi.new('unsigned char[?]', MAX)
    local r = M.get(h, k, b)
    if r >= 0 then
      return ffi.string(b, r)
    else
      return nil, E('get', r)
    end
  end,
  set = function(t, h)
    h = h or LOCALHOST
    if not t.expire then
      t.expire = "0"
    else
      t.expire = tostring(t.expire)
    end
    if #t.value > MAX then
      return nil, E('set', -11)
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
    if #t.value > MAX then
      return nil, E('hset', -11)
    end
    local r = M.hset(h, J.encode(t))
    if r == OK then
      return true
    else
      return nil, E('hset', r)
    end
  end,
  hsetnx = function(t, h)
    h = h or LOCALHOST
    if #t.value > MAX then
      return nil, E('hsetnx', -11)
    end
    local r = M.hsetnx(h, J.encode(t))
    if r == 1 then
      return true
    elseif r == 0 then
      return false
    else
      return nil, E('hsetnx', r)
    end
  end,
  hget = function(t, h)
    h = h or LOCALHOST
    local b = ffi.new('unsigned char[?]', MAX)
    local r = M.hget(h, J.encode(t), b)
    if r >= 0 then
      return ffi.string(b, r)
    else
      return nil, E('hget', r)
    end
  end,
  hdel = function(t, h)
    h = h or LOCALHOST
    local r = M.hdel(h, J.encode(t))
    if r == 1 then
      return true
    elseif r == 0 then
      return false
    else
      return nil, E('hdel', r)
    end
  end,
}
