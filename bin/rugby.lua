local function traceback (message)
  local tp = type(message)
  if tp ~= "string" and tp ~= "number" then return message end
  local debug = _G.debug
  if type(debug) ~= "table" then return message end
  local tb = debug.traceback
  if type(tb) ~= "function" then return message end
  return tb(message, 2)
end
local tuple = table.pack or function(...)
  return {n=select('#', ...), ...}
end
local function docall(f, ...)
  local tp = {...}  -- no need in tuple (string arguments only)
  local F = function() return f(unpack(tp)) end
  local result = tuple(xpcall(F, traceback))
  -- force a complete garbage collection in case of errors
  if not result[1] then collectgarbage("collect") end
  return unpack(result, 1, result.n)
end
local function l_message (pname, msg)
  if pname then io_stderr:write(string_format("%s: ", pname)) end
  io_stderr:write(string_format("%s\n", msg))
  io_stderr:flush()
end
local function getargs (argv, n)
  local arg = {}
  for i=1,#argv do arg[i - n] = argv[i] end
  if _G.arg then
    local i = 0
    while _G.arg[i] do
      arg[i - n] = _G.arg[i]
      i = i - 1
    end
  end
  return arg
end
local function report(status, msg)
  if not status and msg ~= nil then
    msg = (type(msg) == 'string' or type(msg) == 'number') and tostring(msg)
          or "(error object is not a string)"
    l_message(progname, msg);
  end
  return status
end
local function handle_script(argv, n)
  _G.arg = getargs(argv, n)  -- collect arguments
  local fname = argv[n]
  if fname == "-" and argv[n-1] ~= "--" then
    fname = nil  -- stdin
  end
  local status, msg = loadfile(fname)
  if status then
    status, msg = docall(status, unpack(_G.arg))
  end
  return report(status, msg)
end
local argv = {...}
local status = handle_script(argv, 1)
if not status then os_exit(1) end
