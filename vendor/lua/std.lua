local type, pcall, setmetatable, ipairs, next, pairs, error, getmetatable, select =
      type, pcall, setmetatable, ipairs, next, pairs, error, getmetatable, select
local F = string.format

local ring = {}
function ring.new(max_size)
   local hist = { __index = ring }
   setmetatable(hist, hist)
   hist.max_size = max_size
   hist.size = 0
   hist.cursor = 1
   return hist
end
function ring:concat(c)
  local s = ""
  for n=1, #self do
    s = string.format("%s%s%s", s, tostring(self[n]), c)
  end
  return s
end
function ring:table()
  local t = {}
  for n=1, #self do
    t[n] = tostring(self[n])
  end
  return t
end
function ring:push(value)
  if self.size < self.max_size then
    table.insert(self, value)
    self.size = self.size + 1
  else
    self[self.cursor] = value
    self.cursor = self.cursor % self.max_size + 1
  end
end
function ring:iterator()
  local i = 0
  return function()
    i = i + 1
    if i <= self.size then
      return self[(self.cursor - i - 1) % self.size + 1]
    end
  end
end

local pcall_f = function(fn)
  local fix_return_values = function(ok, ...)
    if ok then
      return ...
    else
      return nil, (...)
    end
  end
  return function(...)
    return fix_return_values(pcall(fn, ...))
  end
end

local assert_f = function(fn)
  return function(ok, ...)
    if ok then
      return ok, ...
    else
      if fn then fn(...) end
      error((...), 0)
    end
  end
end

local try_f = function(fn)
  return function(ok, ...)
    if ok then
      return ok, ...
    else
      if fn then return fn(...) end
    end
  end
end

local printf = function(str, ...)
  io.stdout:write(F(str, ...))
  return io.stdout:flush()
end

local echo = function(str)
  io.stdout:write(F("%s\n", str))
  return io.stdout:flush()
end

local fprintf = function(file, str, ...)
  local o = io.output()
  io.output(file)
  local ret, err = io.write(F(str, ...))
  io.output(o)
  return ret, err
end

local warnf = function(str, ...)
  local stderr = io.stderr
  stderr:write(F(str, ...))
  stderr:flush()
end

local panicf = function(str, ...)
  warnf(str, ...)
  os.exit(1)
end

local errorf = function(str, ...)
  return nil, F(str, ...)
end

local assertf = function(v, str, ...)
  if v then
    return true
  else
    panicf(str, ...)
  end
end

local minfo = function(...)
  local str
  if select("#", ...) == 1 then
    str = (...)
  else
    str = F(...)
  end
  io.stdout:write(F("%s[%s] %s+ %sinfo  %s%s\n",  "\27[35m", os.date("%H:%M:%S"), "\27[36m", "\27[34m", "\27[0m", str))
  return io.stdout:flush()
end

local mok = function(...)
  local str
  if select("#", ...) == 1 then
    str = (...)
  else
    str = F(...)
  end
  io.stdout:write(F("%s[%s] %s* %sok    %s%s\n",  "\27[35m", os.date("%H:%M:%S"), "\27[36m", "\27[32m", "\27[0m", str))
  return io.stdout:flush()
end

local mdebug = function(...)
  local str
  if select("#", ...) == 1 then
    str = (...)
  else
    str = F(...)
  end
  io.stdout:write(F("%s[%s] %s. %sdebug %s%s\n",  "\27[35m", os.date("%H:%M:%S"), "\27[36m", "\27[33m", "\27[0m", str))
  return io.stdout:flush()
end

local mfatal = function(...)
  local str
  if select("#", ...) == 1 then
    str = (...)
  else
    str = F(...)
  end
  io.stderr:write(F("%s[%s] %s! %sfatal %s%s\n",  "\27[35m", os.date("%H:%M:%S"), "\27[36m", "\27[31m", "\27[0m", str))
  return io.stderr:flush()
end

local mwarn = function(...)
  local str
  if select("#", ...) == 1 then
    str = (...)
  else
    str = F(...)
  end
  io.stderr:write(F("%s[%s] %s? %swarn  %s%s\n",  "\27[35m", os.date("%H:%M:%S"), "\27[36m", "\27[31m", "\27[0m", str))
  return io.stderr:flush()
end

local append = function(str, a)
  return F("%s\n%s", str, a)
end

local hm = function()
  return os.date("%H:%M")
end


local ymd = function()
  return os.date("%Y-%m-%d")
end

local stamp = function()
  return os.date("%Y-%m-%d %H:%M:%S %Z%z")
end

local t_find = function(tbl, str, plain)
  for _, tval in next, tbl do
    tval = string.gsub(tval, '[%c]', '')
    if string.find(tval, str, 1, plain) then return true end
  end
end

local f_find = function(file, str, plain, fmt)
  fmt = fmt or "*L"
  for s in io.lines(file, fmt) do
    if string.find(s, str, 1, plain) then
      return true
    end
  end
end

local f_match = function(file, str, fmt)
  local m
  fmt = fmt or "*L"
  for s in io.lines(file, fmt) do
    m = string.match(s, str)
    if m then break end
  end
  return m
end

local t_to_dict = function(tbl, def)
  def = def or true
  local t = {}
  for n = 1, #tbl do
    t[tbl[n]] = def
  end
  return t
end

local t_to_seq = function(tbl)
  local t = {}
  for k, _ in pairs(tbl) do
    t[#t+1] = k
  end
  return t
end

local line_to_seq = function(str)
  local tbl = {}
  if not str then
    return tbl
  end
  for ln in string.gmatch(str, "([^\n]*)\n*") do
    tbl[#tbl + 1] = ln
  end
  return tbl
end

local word_to_seq = function(str)
  local t = {}
  for s in string.gmatch(str, "%w+") do
    t[#t + 1] = s
  end
  return t
end

local s_to_seq = function(str)
  local t = {}
  for s in string.gmatch(str, "%S+") do
    t[#t + 1] = s
  end
  return t
end

local t_filter = function(tbl, patt, plain)
  plain = plain or nil
  local s, c = #tbl, 0
  for n = 1, s do
    if string.find(tbl[n], patt, 1, plain) then
      tbl[n] = nil
    end
  end
  for n = 1, s do
    if tbl[n] ~= nil then
      c = c + 1
      tbl[c] = tbl[n]
    end
  end
  for n = c + 1, s do
    tbl[n] = nil
  end
  return tbl
end

local f_to_seq = function(file, fmt)
  fmt = fmt or "*L"
  local _, fd = pcall(io.open, file, 're')
  if fd then
    io.flush(fd)
    local tbl = {}
    for ln in fd:lines(fmt) do
      tbl[#tbl + 1] = ln
    end
    io.close(fd)
    return tbl
  end
end

local split = function(path)
  local l = string.len(path)
  local c = string.sub(path, l, l)
  while l > 0 and c ~= "/" do
    l = l - 1
    c = string.sub(path, l, l)
  end
  if l == 0 then
    return '', path
  else
    return string.sub(path, 1, l - 1), string.sub(path, l + 1)
  end
end


local test = function(file)
  local f = io.open(file, "rb")
  if f then
    io.close(f)
    return true
  end
end

local f_read = function(file)
  if not test(file) then
    return nil, "io.open: File not found or no permissions to read file."
  end
  local str = ""
  for s in io.lines(file, 2^12) do
    str = F("%s%s", str, s)
  end
  return str
end

local f_write = function(path, str, mode)
  mode = mode or "w+"
  local fd = io.open(path, mode)
  if fd then
    fd:setvbuf("no")
    local _, err = fd:write(str)
    io.flush(fd)
    io.close(fd)
    if err then
      return nil, err
    end
    return true
  end
  return nil, "io.open: File not found or no permissions to write file."
end

local f_line = function(file, ln)
  local i = 0
  for l in io.lines(file) do
    i = i + 1
    if i == ln then return l end
  end
end

local template = function(s, v)
  return (string.gsub(s, "%${[%s]-([^}%G]+)[%s]-}", v))
end

local truthy = function(s)
  local _
  _, s = pcall(string.lower, s)
  if s == "yes" or s == "true" or s == "on" then
    return true
  end
end

local falsy = function(s)
  local _
  _, s = pcall(string.lower, s)
  if s == "no" or s == "false" or s == "off" then
    return true
  end
end

local script = function(str, ignore)
  local R = {}
  local pipe = io.popen(f_read(str), "r")
  io.flush(pipe)
  R.output = {}
  for ln in pipe:lines() do
    R.output[#R.output + 1] = ln
  end
  local _, status, code = io.close(pipe)
  R.exe = "io.popen"
  R.code = code
  R.status = status
  if code == 0 or ignore then
    return code, R
  else
    return nil, R
  end
end

local pctx = function()
  local ring = require "ring"
  local set = {}
  set.errexit = true
  set.unset = true
  set.noglob = true
  set.pipefail = false
  set.ignore = false
  set.clear = true
  set.template = nil
  set.size = 25
  return setmetatable(set, {__call = function(_, ...)
    local line
    local str
    if select("#", ...) > 1 then
      line = F(...)
    elseif set.template and next(set.template) then
      line = template(..., set.template)
    else
      line = (...)
    end
    str = line
    local hdr_env = "#export ENV"
    if set.env and next(set.env) then
      local e = {}
      for k,v in pairs(set.env) do
        e[#e+1] = F("export %s=%s", k,v )
      end
      hdr_env = table.concat(e, "\n")
    end
    local hdr_errexit = set.errexit and [[set -e]] or "#set -e"
    local hdr_unset = set.unset and [[set -u]] or "#set -u"
    local hdr_noglob = set.noglob and [[set -f]] or "#set -f"
    local hdr_pipefail = set.pipefail and [[set -o pipefail]] or "#set -o pipefail"
    local hdr_clear = set.clear and [[for i in $(env | cut -f 1 -d=) ; do unset $i ; done]] or "#clear environment"
    local hdr_ifs  = [[unset IFS]]
    local hdr_lc   = [[export LC_ALL=C]]
    local hdr_path = [[export PATH=/bin:/sbin:/usr/bin:/usr/sbin]]
    local hdr_out  = [[exec 2>&1]]
    local hdr = F("%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n",
      hdr_errexit, hdr_unset, hdr_noglob, hdr_pipefail, hdr_clear, hdr_ifs, hdr_lc, hdr_path, hdr_env, hdr_out)
    if set.cwd then
      hdr = F("%scd %s\n", hdr, set.cwd)
    end
    if set.input then
      hdr = F("%sprintf '%s' |\n", hdr, set.input)
    end
    str = F(str, ...)
    str = F("%s%s", hdr, str)
    if set.dump then
      print(F(">>>> SCRIPT DUMP START <<<<\n%s\n>>>> SCRIPT DUMP END   <<<<", str))
      os.exit(0)
    end
    local R = {}
    local pipe = io.popen(str, "r")
    io.flush(pipe)
    local buffer = ring.new(set.size)
    for ln in pipe:lines() do
      buffer:push(ln)
    end
    local _, status, code = io.close(pipe)
    if code ~= 0 and not set.ignore then
      return panicf("<%s:%s> %s\n  -- OUTPUT --\n%s\n", status, code, line, buffer:concat("\n"))
    end
    R.output = buffer:table()
    return code, R
  end})
end
--[=[
    local cmd = exec.ctx()
    cmd.ignore = true
    cmd.cwd = "/tmp"
    cmd.input = "test"
    cmd.dump = true
    cmd("ls %s", var)

]=]

local time = function(f, ...)
  local t1 = os.time()
  local fn = {f(...)}
  fn[#fn+1] = os.difftime(os.time(), t1)
  return table.unpack(fn)
end

local escape_quotes = function(str)
  str = string.gsub(str, [["]], [[\"]])
  str = string.gsub(str, [[']], [[\']])
  return str
end

local l_file = function(file, ident, msg)
  local fd = io.open(file, "a+")
  if fd then
    fd:setvbuf("line")
    local _, err = fprintf(fd, "%s %s: %s\n", os.date("%a %b %d %T"), ident, msg)
    io.flush(fd)
    io.close(fd)
    if err then
      return nil, err
    end
    return true
  end
  return nil, "log.file: Cannot open file."
end

local insert_if = function(bool, list, pos, value)
  if bool then
    if type(value) == "table" then
      for n, i in ipairs(value) do
        local p = n - 1
        table.insert(list, pos + p, i)
      end
    else
      if pos == -1 then
        table.insert(list, value)
      else
        table.insert(list, pos, value)
      end
    end
  end
end

local return_if = function(bool, value)
  if bool then
    return (value)
  end
end

local return_if_not = function(bool, value)
  if bool == false or bool == nil then
    return value
  end
end

local autotable
local auto_meta = {
  __index = function(t, k)
    t[k] = autotable()
    return t[k]
  end
}
autotable = function(t)
  t = t or {}
  local meta = getmetatable(t)
  if meta then
    assert(not meta.__index or meta.__index == auto_meta.__index, "__index already set")
    meta.__index = auto_meta.__index
  else
    setmetatable(t, auto_meta)
  end
  return t
end

local t_len = function(t, maxn)
  local n = 0
  if maxn then
    for _ in pairs(t) do
      n = n + 1
      if n >= maxn then break end
    end
  else
    for _ in pairs(t) do
      n = n + 1
    end
  end
  return n
end

local t_count = function(t, i)
  local n = 0
  for _, v in pairs(t) do
    if i == v then
      n = n + 1
    end
  end
  return n
end

local t_unique = function(t)
  local nt = {}
  for _, v in pairs(t) do
    if t_count(nt, v) == 0 then
      nt[#nt+1] = v
    end
  end
  return nt
end

local truncate = function(file)
  local o = io.output()
  local fd = io.open(file, "w+")
  if fd then
    io.output(fd)
    io.write("")
    io.close()
    io.output(o)
    return true
  end
  return nil, "io.open: Cannot open path."
end

local read_all = function(file)
  local o = io.input()
  local fd = io.open(file)
  io.input(fd)
  local str = io.read("*a")
  io.close()
  io.input(o)
  return str
end

local head = function(file)
  local o = io.input()
  local fd = io.open(file)
  io.input(fd)
  local str = io.read("*l")
  io.close()
  io.input(o)
  return str
end

-- From: http://lua-users.org/wiki/HexDump
-- [first] begin dump at 16 byte-aligned offset containing 'first' byte
-- [last] end dump at 16 byte-aligned offset containing 'last' byte
local hexdump = function(buf, first, last)
  local function align(n) return math.ceil(n/16) * 16 end
  for i=(align((first or 1)-16)+1),align(math.min(last or #buf,#buf)) do
    if (i-1) % 16 == 0 then io.write(F('%08X  ', i-1)) end
    io.write( i > #buf and '   ' or F('%02X ', buf:byte(i)) )
    if i %  8 == 0 then io.write(' ') end
    if i % 16 == 0 then io.write( buf:sub(i-16+1, i):gsub('%c','.'), '\n' ) end
  end
end

local escape_sql = function(v)
  local vt = type(v)
  if "string" == vt then
    local s = "'" .. (v:gsub("'", "''")) .. "'"
    return (s:gsub(string.char(0,9,10,11,12,13,14), ""))
  elseif "boolean" == vt then
    return v and "TRUE" or "FALSE"
  end
end

return {
  ring = ring,
  tbl = {
    find = t_find,
    to_dict = t_to_dict,
    to_hash = t_to_dict,
    to_seq = t_to_seq,
    to_array = t_to_seq,
    filter = t_filter,
    insert_if = insert_if,
    auto = autotable,
    len = t_len,
    count = t_count,
    unique = t_unique,
    uniq = t_unique,
  },
  str = {
    append = append,
    line_to_table = line_to_seq,
    line_to_array = line_to_seq,
    word_to_table = word_to_seq,
    word_to_array = word_to_seq,
    to_seq   = s_to_seq,
    to_table = s_to_seq,
    to_array = s_to_seq,
    template = template,
    escape_quotes = escape_quotes,
    hexdump = hexdump,
  },
  func = {
    pcall_f = pcall_f,
    pcall = pcall_f,
    assert_f = assert_f,
    assert = assert_f,
    try_f = try_f,
    try = try_f,
    time = time
  },
  fmt = {
    printf = printf,
    print = printf,
    fprintf = fprintf,
    fprint = fprintf,
    warnf = warnf,
    warn = warnf,
    errorf = errorf,
    error = errorf,
    panicf = panicf,
    panic = panicf,
    assertf = assertf,
    assert = assertf
  },
  msg = {
    ok = mok,
    debug = mdebug,
    fatal = mfatal,
    warn = mwarn,
    info = minfo
  },
  time = {
    hm = hm,
    ymd = ymd,
    stamp = stamp
  },
  file = {
    find = f_find,
    match = f_match,
    to_table = f_to_seq,
    to_array = f_to_seq,
    test = test,
    read_to_string = f_read,
    read = f_read,
    write_all = f_write,
    write = f_write,
    line = f_line,
    truncate = truncate,
    read_all = read_all,
    head = head,
  },
  exec = {
    script = script,
    ctx = pctx
  },
  util = {
    log = l_file,
    truthy = truthy,
    falsy = falsy,
    return_if = return_if,
    return_if_not = return_if_not,
    echo = echo,
    split = split,
    escape_sql = escape_sql,
  }
}
