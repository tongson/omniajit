local lib = require"lib"
local util = lib.util
local exec = lib.exec
local json = require"lunajson"
local F = string.format
local popen = exec.ctx()
popen.ignore = true


local user_agent = [[-A 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:70.0) Gecko/20100101 Firefox/70.0']]
local defhdrs = [[-H 'Transfer-Encoding: chunked' -H 'Connection: keep-alive' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache']]
local defopts = [[--retry 20 -m 5 --retry-delay 1 -s --tcp-fastopen --tcp-nodelay --http1.1 --location --referer ';auto']]

local json = function()
  local headers = [[-H 'Content-Type: application/json' -H 'Accept: application/json']]
  local set = {}
  set.headers = {}
  set.insecure = false
  set.save = false
  return setmetatable(set, {__call = function(_, url)
    local curl_cookie = set.cookie or "/tmp/"..util.random_string(16)
    local curl_insecure, curl_jar, curl_data
    if next(set.headers) then
      for h, v in pairs(set.headers) do
        headers = headers .. (F(" -H '%s: %s'", h, v))
      end
    end
    if set.save then
      curl_jar = F("-b %s -c %s", curl_cookie, curl_cookie)
    else
      curl_jar = F("-b %s", curl_cookie)
    end
    if set.insecure then
      curl_insecure = "-k"
    end
    if set.data then
      curl_data = F("-d '%s'", set.data)
      -- clear for next run
      set.data = nil
      set.curl = F("curl %s %s %s %s %s %s %s %s", curl_data, curl_jar, headers, user_agent, defopts, defhdrs, curl_insecure or "", url)
    else
      set.curl = F("curl %s %s %s %s %s %s %s", curl_jar, headers, user_agent, defopts, defhdrs, curl_insecure or "", url)
    end
    local n, r = popen(set.curl)
    if n == 0 then
      local ret, _, err = json.decode(r.output[1])
      if err then
        return nil, err
      else
        return ret
      end
    else
      return nil, F("error: popen: %s: %s", n, table.concat(r.output, "\n"))
    end
  end})
end

local encoded = function()
  local headers = [[-H 'Content-Type: application/x-www-form-urlencode' -H 'Accept: */*']]
  local set = {}
  set.headers = {}
  set.insecure = false
  set.save = false
  return setmetatable(set, {__call = function(_, url)
    local curl_cookie = set.cookie or "/tmp/"..util.random_string(16)
    local curl_insecure, curl_jar, curl_data
    if next(set.headers) then
      for h, v in pairs(set.headers) do
        headers = headers .. (F(" -H '%s: %s'", h, v))
      end
    end
    if set.save then
      curl_jar = F("-b %s -c %s", curl_cookie, curl_cookie)
    else
      curl_jar = F("-b %s", curl_cookie)
    end
    if set.insecure then
      curl_insecure = "-k"
    end
    if set.data then
      curl_data = F("--data-urlencode '%s'", set.data)
      -- clear for next run
      set.data = nil
      set.curl = F("curl %s %s %s %s %s %s %s %s", curl_data, curl_jar, headers, user_agent, defopts, defhdrs, curl_insecure or "", url)
    else
      set.curl = F("curl %s %s %s %s %s %s %s", curl_jar, headers, user_agent, defopts, defhdrs, curl_insecure or "", url)
    end
    local n, r = popen(set.curl)
    if n == 0 then
      return table.concat(r.output, "\n")
    else
      return nil, F("error: popen: %s: %s", n, table.concat(r.output, "\n"))
    end
  end})
end
local get = function()
  local headers = [[-H 'Accept: */*']]
  local set = {}
  set.headers = {}
  set.insecure = false
  set.save = false
  return setmetatable(set, {__call = function(_, url)
    local curl_cookie = set.cookie or "/tmp/"..util.random_string(16)
    local curl_insecure, curl_jar, curl_data
    if next(set.headers) then
      for h, v in pairs(set.headers) do
        headers = headers .. (F(" -H '%s: %s'", h, v))
      end
    end
    if set.save then
      curl_jar = F("-b %s -c %s", curl_cookie, curl_cookie)
    else
      curl_jar = F("-b %s", curl_cookie)
    end
    if set.insecure then
      curl_insecure = "-k"
    end
    set.curl = F("curl %s %s %s %s %s %s %s", curl_jar, headers, user_agent, defopts, defhdrs, curl_insecure or "", url)
    local n, r = popen(set.curl)
    if n == 0 then
      return table.concat(r.output, "\n")
    else
      return nil, F("error: popen: %s: %s", n, table.concat(r.output, "\n"))
    end
  end})
end
local head = function()
  local headers = [[-H 'Accept: */*']]
  local opts = [[-o /dev/null -I -s -w '%%{http_code}']]
  local set = {}
  set.headers = {}
  set.insecure = false
  set.save = false
  return setmetatable(set, {__call = function(_, url)
    local curl_cookie = set.cookie or "/tmp/"..util.random_string(16)
    local curl_insecure, curl_jar, curl_data
    if next(set.headers) then
      for h, v in pairs(set.headers) do
        headers = headers .. (F(" -H '%s: %s'", h, v))
      end
    end
    if set.save then
      curl_jar = F("-b %s -c %s", curl_cookie, curl_cookie)
    else
      curl_jar = F("-b %s", curl_cookie)
    end
    if set.insecure then
      curl_insecure = "-k"
    end
    set.curl = F([[curl %s %s %s %s %s %s %s %s]], opts, curl_jar, headers, user_agent, defopts, defhdrs, curl_insecure or "", url)
    local n, r = popen(set.curl)
    if n == 0 then
      return table.concat(r.output, "\n")
    else
      return nil, F("error: popen: %s: %s", n, table.concat(r.output, "\n"))
    end
  end})
end



return {
  json = json,
  encoded = encoded,
  get = get,
  head = head,
}
