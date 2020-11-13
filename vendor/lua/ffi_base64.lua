-- https://github.com/kengonakajima/luvit-base64/issues/1
local string = require("string")
local b = require('bit')
local math = require('math')
local table = require('table')
local ffi = require('ffi')


local base64_table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local Base64Digits8192 = ffi.new("short[?]", 4096)

local b64chars = ffi.new("char[?]", #base64_table+1)
ffi.copy(b64chars, base64_table)

-- calculate LUT
for j=0,63,1 do
  for k=0,63,1 do
    local w = b.lshift(b64chars[k],8)
    w = b.bor(w, b64chars[j])
    Base64Digits8192[j*64+k]=w
  end
end

local CHAR_EQUAL = string.byte('=')

local base64_fast = function(data)
  local nLenSrc = #data
  local nLenOut = math.floor((nLenSrc+2)/3)*4
  local pDst = ffi.new("char[?]", nLenOut+1)
  local pSrc = ffi.new("char[?]", nLenSrc+1)
  ffi.copy(pSrc, data)
  local pwDst = ffi.cast("short*", pDst)
  local sCnt = 0
  local dCnt = 0

  while( nLenSrc > 2) do
    local n = pSrc[sCnt]
    n = b.lshift(n, 8)
    n = b.bor(n, pSrc[sCnt+1])
    n = b.lshift(n, 8)
    n = b.bor(n, pSrc[sCnt+2])
    local n1 = b.rshift(n, 12)
    local n2 = b.band(n, 0x00000fff)
    pwDst[dCnt] = Base64Digits8192[ n1 ]
    pwDst[dCnt+1] = Base64Digits8192[ n2 ]
    nLenSrc = nLenSrc - 3
    dCnt = dCnt + 2
    sCnt = sCnt + 3
  end

  dCnt = dCnt * 2

  if nLenSrc > 0 then
    local n1 = b.rshift(b.band(pSrc[sCnt], 0xfc),2)
    local n2 = b.lshift(b.band(pSrc[sCnt], 0x03),4)
    if nLenSrc > 1 then
      sCnt = sCnt + 1
      n2 = b.bor(n2, b.rshift(b.band(pSrc[sCnt], 0xf0),4))
    end
    pDst[dCnt] = b64chars[n1];
    pDst[dCnt+1] = b64chars[n2];
    dCnt = dCnt + 2
    if nLenSrc == 2 then
      local n3 = b.lshift(b.band(pSrc[sCnt], 0xf),2)
      sCnt = sCnt + 1
      n3 = b.bor(n3, b.rshift(b.band(pSrc[sCnt], 0xc0),6))
      pDst[dCnt] = b64chars[n3]
      dCnt = dCnt + 1
    end
    if nLenSrc == 1 then
      pDst[dCnt] = CHAR_EQUAL
      dCnt = dCnt + 1
    end
    pDst[dCnt] = CHAR_EQUAL
  end
  return ffi.string(pDst, nLenOut)
end

return {
	encode = base64_fast,
}
