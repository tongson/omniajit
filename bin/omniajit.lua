local script = arg[1]
local lib = require "cimicida"
local ENV = lib
setmetatable(ENV, {__index = _G})
local string, fmt, file, path = lib.string, lib.fmt, lib.file, lib.path
package.path = path.split(script)
local code = file.read_all(script)
if not code then
  return fmt.panic("error: problem reading script '%s'.\n", script )
end
local source
if string.find(script, "fnl", "-3", true) then
  local fennel = require "fennel"
  local ok
  ok, source = pcall(fennel.compileString, code)
  if not ok then
    return fmt.panic("error: problem transpiling Fennel script.\n")
  end
else
  source = code
end
local chunk, err = loadstring(source)
if chunk then
  setfenv(chunk, ENV)
  return chunk()
else
  local tbl = {}
  for ln in string.gmatch(source, "([^\n]*)\n*") do
    tbl[#tbl + 1] = ln
  end
  local ln = string.match(err, "^.+:([%d]):.*")
  local sp = string.rep(" ", string.len(ln))
  err = string.match(err, "^.+:[%d]:(.*)")
  return fmt.panic("error: %s\n%s |\n%s | %s\n%s |\n", err, sp, ln, tbl[tonumber(ln)], sp)
end
