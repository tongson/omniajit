local type, pcall, setmetatable, ipairs, next, pairs, error, getmetatable =
      type, pcall, setmetatable, ipairs, next, pairs, error, getmetatable
local F = string.format

local fix_return_values = function(ok, ...)
  if ok then
    return ...
  else
    return nil, (...)
  end
end

local pcall_f = function(fn)
  return function(...)
    return fix_return_values(pcall(fn, ...))
  end
end

local try_f = function(fn)
  return function(ok, ...)
    if ok then
      return ok, ...
    else
      if fn then fn(...) end
      error((...), 0)
    end
  end
end

local catch_f = function(fn)
  return function(ok, ...)
    if ok then
      return ok, ...
    else
      if fn then return fn(...) end
    end
  end
end

local printf = function(str, ...)
  io.stdout:write(string.format(str, ...))
  return io.stdout:flush()
end

local echo = function(str)
  io.stdout:write(string.format("%s\n", str))
  return io.stdout:flush()
end

local uprint = function(str)
  io.stdout:write(str)
  return io.stdout:flush()
end

local fprintf = function(file, str, ...)
  local o = io.output()
  io.output(file)
  local ret, err = printf(str, ...)
  io.output(o)
  return ret, err
end

local warnf = function(str, ...)
  return fprintf(io.stderr, str, ...)
end

local panicf = function(str, ...)
  warnf(str, ...)
  os.exit(1)
end

local errorf = function(str, ...)
  return nil, string.format(str, ...)
end

local assertf = function(v, str, ...)
  if v then
    return true
  else
    errorf(str, ...)
  end
end

local minfo = function(str)
  io.stdout:write(string.format("%s[%s] %s+ %sinfo  %s%s\n",  "\27[35m", os.date("%H:%M:%S"), "\27[36m", "\27[34m", "\27[0m", str))
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
  return string.format("%s\n%s", str, a)
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

local escape_pattern = function(str, mode)
  local format_ci_pat = function(c)
    return string.format('[%s%s]', c:lower(), c:upper())
  end
  str = str:gsub('%%','%%%%'):gsub('%z','%%z'):gsub('([%^%$%(%)%.%[%]%*%+%-%?])', '%%%1')
  if mode == '*i' then
    str = str:gsub('[%a]', format_ci_pat)
  end
  return str
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

local clone
clone = function(tbl, seen)
  seen = seen or {}
  if tbl == nil then
    return nil, "Table to be copied required."
  end
  local new
  if type(tbl) == "table" then
    new = {}
    seen[tbl] = new
    for k, v in next, tbl, nil do
      new[clone(k, seen)] = clone(v, seen)
    end
    setmetatable(new, clone(getmetatable(tbl), seen))
  else
    new = tbl
  end
  return new
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
    str = string.format("%s%s", str, s)
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

local pwrite = function(str, data, cwd, ignore)
  local header = [[  set -ef
  unset IFS
  export LC_ALL=C
  ]]
  if cwd then
    str = string.format("%scd %s\nexec %s", header, cwd, str)
  else
    str = string.format("%sexec %s", header, str)
  end
  local pipe = io.popen(str, "w")
  io.flush(pipe)
  pipe:write(data)
  local R = {}
  local _, status, code = io.close(pipe)
  R.exe = "io.popen"
  R.status = status
  if code == 0 or ignore then
    return code, R
  else
    return nil, R
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
  local set = {}
  return setmetatable(set, {__call = function(_, ...)
    local line
    local str
    if select("#", ...) == 1 then
      line = (...)
    else
      line = F(...)
    end
    str = line
    local hdr_ifs  = [[unset IFS]]
    local hdr_lc   = [[export LC_ALL=C]]
    local hdr_path = [[export PATH=/bin:/sbin:/usr/bin:/usr/sbin]]
    local hdr_out  = [[exec 2>&1]]
    local hdr = F("%s\n%s\n%s\n%s\n", hdr_ifs, hdr_lc, hdr_path, hdr_out)
    local hdr_set  = [[set -efu]]
    if not set.ignore then
      hdr = F("%s\n%s", hdr_set, hdr)
    end
    if set.cwd then
      hdr = F("%scd %s\n", hdr, set.cwd)
    end
    if set.input then
      hdr = F("%sprintf '%s' |\n", hdr, set.input)
    end
    str = string.format(str, ...)
    str = F("%s%s", hdr, str)
    if set.dump then
      print(F(">>>> SCRIPT DUMP START <<<<\n%s\n>>>> SCRIPT DUMP END   <<<<", str))
      os.exit(0)
    end
    local R = {}
    local pipe = io.popen(str, "r")
    io.flush(pipe)
    R.output = {}
    for ln in pipe:lines() do
      R.output[#R.output + 1] = ln
    end
    local _, status, code = io.close(pipe)
    if code ~= 0 and not set.ignore then
      return panicf("<%s:%s> %s\n  -- OUTPUT --\n%s\n", status, code, line, table.concat(R.output, "\n"))
    end
    return R
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

local random_string
random_string = function(length)
  local charset = {}
  do -- [0-9a-zA-Z]
    for c = 48, 57  do table.insert(charset, string.char(c)) end
    for c = 65, 90  do table.insert(charset, string.char(c)) end
    for c = 97, 122 do table.insert(charset, string.char(c)) end
  end
  if not length or length <= 0 then return '' end
  math.randomseed(os.clock()^5)
  return random_string(length - 1) .. charset[math.random(1, #charset)]
end

-- From: http://lua-users.org/wiki/HexDump
-- [first] begin dump at 16 byte-aligned offset containing 'first' byte
-- [last] end dump at 16 byte-aligned offset containing 'last' byte
local hexdump = function(buf, first, last)
  local function align(n) return math.ceil(n/16) * 16 end
  for i=(align((first or 1)-16)+1),align(math.min(last or #buf,#buf)) do
    if (i-1) % 16 == 0 then io.write(string.format('%08X  ', i-1)) end
    io.write( i > #buf and '   ' or string.format('%02X ', buf:byte(i)) )
    if i %  8 == 0 then io.write(' ') end
    if i % 16 == 0 then io.write( buf:sub(i-16+1, i):gsub('%c','.'), '\n' ) end
  end
end

return {
  tbl = {
    find = t_find,
    to_dict = t_to_dict,
    to_hash = t_to_dict,
    to_seq = t_to_seq,
    to_array = t_to_seq,
    filter = t_filter,
    clone = clone,
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
    to_table = s_to_seq,
    to_array = s_to_seq,
    escape_pattern = escape_pattern,
    template = template,
    escape_quotes = escape_quotes,
    hexdump = hexdump,
  },
  func = {
    pcall_f = pcall_f,
    pcall = pcall_f,
    try_f = try_f,
    try = try_f,
    catch_f = catch_f,
    catch = catch_f,
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
    pwrite = pwrite,
    script = script,
    ctx = pctx
  },
  log = {
    file = l_file
  },
  util = {
    truthy = truthy,
    falsy = falsy,
    return_if = return_if,
    return_if_not = return_if_not,
    echo = echo,
    print = uprint,
    random_string = random_string,
    split = split
  }
}


