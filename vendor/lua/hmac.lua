local ffi = require 'ffi'
local bit = require 'bit'
local Hash = require 'blake3'.hash
local Rep = string.rep
local Char = string.char

local xor = function(s1, s2)
  local buf = ffi.new('uint8_t[?]', #s1)
  for i=1,#s1 do
    buf[i-1] = bit.bxor(s1:byte(i,i), s2:byte(i,i))
  end
  return ffi.string(buf, #s1)
end
local opad = function(key)
  return xor(key, Rep(Char(0x5c), 64))
end
local ipad = function(key)
  return xor(key, Rep(Char(0x36), 64))
end
local compute = function(key, msg, op, ip)
  if #key > 64 then
    key = Hash(key)
  end
  key = key..Rep('\0', 64-#key)
  op = op or opad(key)
  ip = ip or ipad(key)
  return Hash(op..Hash(ip..msg))
end
