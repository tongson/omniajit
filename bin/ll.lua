local function traceback (message)
  local tp = type(message)
  if tp ~= "string" and tp ~= "number" then return message end
  local debug = _G.debug
  if type(debug) ~= "table" then return message end
  local tb = debug.traceback
  if type(tb) ~= "function" then return message end
  return tb(message, 2)
end
local function l_message (pname, msg)
  local stderr = io.stderr
  local format = string.format
  if pname then stderr:write(format("%s: ", pname)) end
  stderr:write(format("%s\n", msg))
  stderr:flush()
end
local function getargs (argv)
  local arg = {}
  for i=1,#argv do arg[i - 1] = argv[i] end
  if _G.arg then
    local i = 0
    while _G.arg[i] do
      arg[i - 1] = _G.arg[i]
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
local function handle_script(argv)
  _G.arg = getargs(argv)  -- collect arguments
  local fname = argv[1]
  local status, msg = loadfile(fname)
  if status then
    status, msg = xpcall(status, traceback, unpack(_G.arg))
    -- force a complete garbage collection in case of errors
    if not status then collectgarbage("collect") end
  end
  return report(status, msg)
end
do
  local argv = arg
  if not handle_script(argv) then os.exit(1) end
end
