local clone = require"table.clone"
local function traceback (message)
  local tp = type(message)
  if tp ~= "string" and tp ~= "number" then return message end
  local debug = _G.debug
  if type(debug) ~= "table" then return message end
  local tb = debug.traceback
  if type(tb) ~= "function" then return message end
  return tb(message, 4)
end
local function l_message (pname, msg)
  local stderr = io.stderr
  local format = string.format
  if pname then stderr:write(format("%s: ", pname)) end
  stderr:write(format("%s\n", msg))
  stderr:flush()
end
local function getargs()
  local a = clone(_G.arg)
  for i=1,#a do a[i - 1] = _G.arg[i] end
  return a
end
local function report(status, msg)
  if not status and msg ~= nil then
    msg = (type(msg) == 'string' or type(msg) == 'number') and tostring(msg)
          or "(error object is not a string)"
    l_message(progname, msg);
  end
  return status
end
do
  local fname = _G.arg[1]
  _G.arg = getargs()
  local status, msg = loadfile(fname)
  if status then
    status, msg = xpcall(status, traceback, _G.arg)
    -- force a complete garbage collection in case of errors
    if not status then collectgarbage("collect") end
    if not report(status, msg) then os.exit(1) end
  end
end
os.exit(0)
