local ffi = require 'ffi'
ffi.cdef [[
const char *del(const char *);
const char *incr(const char *);
const char *get(const char *);
const char *set(const char *);
]]
local p = arg.path.ffi or '.'
local M = ffi.load(p..'/librediz.so')
local C = string.char
local J = require 'json'
local B = require 'base64'

return {
  del = function(k)
    local r = ffi.string(M.del(k))
    if     r == C(6) then
      return true
    elseif r == C(21) then
      return nil, "redis.del: Error in query."
    elseif r == C(20) then
      return nil, "redis.del: Unable to connect to redis."
    elseif r == C(18) then
      return nil, "redis.del: Error preparing client."
    end
  end,
  incr = function(k)
    local r = ffi.string(M.incr(k))
    if     r == C(6) then
      return true
    elseif r == C(21) then
      return nil, "redis.incr: Error in query."
    elseif r == C(20) then
      return nil, "redis.incr: Unable to connect to redis."
    elseif r == C(18) then
      return nil, "redis.incr: Error preparing client."
    end
  end,
  get = function(k)
    local r = ffi.string(M.get(k))
    if     r == C(21) then
      return nil, "redis.get: Error in query."
    elseif r == C(20) then
      return nil, "redis.get: Unable to connect to redis."
    elseif r == C(18) then
      return nil, "redis.get: Error preparing client."
    elseif r == "" then
      return nil, "redis.get: Empty."
    else
      return r
    end
  end,
  set = function(t)
    if not t.expire then
      t.expire = "0"
    else
      t.expire = tostring(t.expire)
    end
    local r = ffi.string(M.set(J.encode(t)))
    if     r == C(6) then
      return true
    elseif r == C(21) then
      return nil, "redis.set: Error in query."
    elseif r == C(20) then
      return nil, "redis.set: Unable to connect to redis."
    elseif r == C(18) then
      return nil, "redis.set: Error preparing client."
    end
  end,
}
