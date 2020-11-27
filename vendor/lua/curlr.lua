local clone = require 'table.clone'
local exec = require 'exec'
local json = require 'json'
local ffi_ext = require 'ffi_ext'
local random_string = ffi_ext.random_string
local F = string.format

local args = {
  '-A',
  [['Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:70.0) Gecko/20100101 Firefox/70.0']],
  '-H', [['Transfer-Encoding: chunked']],
  '-H', [['Connection: keep-alive']],
  '-H', [['Pragma: no-cache']],
  '-H', [['Cache-Control: no-cache']],
  '--retry', '20',
  '-m', '5',
  '--retry-delay', '1',
  '-s',
  '--tcp-fastopen',
  '--tcp-nodelay',
  '--http1.1',
  '--location',
  '--referer', [[';auto']],
}

local json = function()
  local a = clone(args)
  a[#a+1] = '-H'
  a[#a+1] = [['Content-Type: application/json']]
  a[#a+1] = '-H'
  a[#a+1] = [['Accept: application/json']]
  local set = {}
  set.headers = {}
  set.insecure = false
  set.save = false
  return setmetatable(set, {__call = function(_, url)
    local cookie = set.cookie or '/tmp/'..random_string(16)
    if next(set.headers) then
      for h, v in pairs(set.headers) do
        a[#a+1] = '-H'
        a[#a+1] = F([['%s: %s']], h, v)
      end
    end
    if set.save then
      a[#a+1] = '-b'
      a[#a+1] = cookie
      a[#a+1] = '-c'
      a[#a+1] = cookie
    else
      a[#a+1] = '-b'
      a[#a+1] = cookie
    end
    if set.insecure then
      a[#a+1] = '-k'
    end
    if set.data then
      a[#a+1] = '-d'
      a[#a+1] = F([['%s']], set.data)
      -- clear for next run
      set.data = nil
    end
    a[#a+1] = url
    local n, r = exec.spawn('/usr/bin/curl', a)
    if n then
      local ret, s = pcall(json.decode, r.stdout[1])
      if not ret then
        return nil, s
      else
        return s
      end
    else
      return nil, F("error: exec:: %s: %s", n, r.error)
    end
  end})
end

local encoded = function()
  local a = clone(args)
  a[#a+1] = '-H'
  a[#a+1] = [['Content-Type: application/x-www-form-urlencoded']]
  a[#a+1] = '-H'
  a[#a+1] = [['Accept: */*']]
  local set = {}
  set.headers = {}
  set.insecure = false
  set.save = false
  return setmetatable(set, {__call = function(_, url)
    local cookie = set.cookie or '/tmp/'..random_string(16)
    if next(set.headers) then
      for h, v in pairs(set.headers) do
        a[#a+1] = '-H'
        a[#a+1] = F([['%s: %s']], h, v)
      end
    end
    if set.save then
      a[#a+1] = '-b'
      a[#a+1] = cookie
      a[#a+1] = '-c'
      a[#a+1] = cookie
    else
      a[#a+1] = '-b'
      a[#a+1] = cookie
    end
    if set.insecure then
      a[#a+1] = '-k'
    end
    if set.data then
      a[#a+1] = '--data-urlencode'
      a[#a+1] = F([['%s']], set.data)
      -- clear for next run
      set.data = nil
    end
    a[#a+1] = url
    local n, r = exec.spawn('/usr/bin/curl', a)
    if n then
      return table.concat(r.stdout, "\n")
    else
      return nil, F("error: exec:: %s: %s", n, table.concat(r.stderr, "\n"))
    end
  end})
end
local get = function()
  local a = clone(args)
  a[#a+1] = '-H'
  a[#a+1] = [['Accept: */*']]
  local set = {}
  set.headers = {}
  set.insecure = false
  set.save = false
  return setmetatable(set, {__call = function(_, url)
    local cookie = set.cookie or "/tmp/"..random_string(16)
    if next(set.headers) then
      for h, v in pairs(set.headers) do
        a[#a+1] = '-H'
        a[#a+1] = F([['%s: %s']], h, v)
      end
    end
    if set.save then
      a[#a+1] = '-b'
      a[#a+1] = cookie
      a[#a+1] = '-c'
      a[#a+1] = cookie
    else
      a[#a+1] = '-b'
      a[#a+1] = cookie
    end
    if set.insecure then
      a[#a+1] = '-k'
    end
    a[#a+1] = url
    local n, r = exec.spawn('/usr/bin/curl', a)
    if n then
      return table.concat(r.stdout, "\n")
    else
      return nil, F("error: exec:: %s: %s", n, table.concat(r.stderr, "\n"))
    end
  end})
end
local head = function()
  local a = clone(args)
  a[#a+1] = '-H'
  a[#a+1] = [['Accept: */*']]
  a[#a+1] = '-o'
  a[#a+1] = '/dev/null'
  a[#a+1] = '-I'
  a[#a+1] = '-s'
  a[#a+1] = '-w'
  a[#a+1] = [['%{http_code}']]
  local set = {}
  set.headers = {}
  set.insecure = false
  set.save = false
  return setmetatable(set, {__call = function(_, url)
    local cookie = set.cookie or "/tmp/"..random_string(16)
    if next(set.headers) then
      for h, v in pairs(set.headers) do
        a[#a+1] = '-H'
        a[#a+1] = F([['%s: %s']], h, v)
      end
    end
    if set.save then
      a[#a+1] = '-b'
      a[#a+1] = cookie
      a[#a+1] = '-c'
      a[#a+1] = cookie
    else
      a[#a+1] = '-b'
      a[#a+1] = cookie
    end
    if set.insecure then
      a[#a+1] = '-k'
    end
    a[#a+1] = url
    local n, r = exec.spawn('/usr/bin/curl', a)
    if n then
      return table.concat(r.stdout, "\n")
    else
      return nil, F("error: exec:: %s: %s", n, table.concat(r.stderr, "\n"))
    end
  end})
end



return {
  json = json,
  encoded = encoded,
  get = get,
  head = head,
}
