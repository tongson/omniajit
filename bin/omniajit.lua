local script = arg[1]
local lib = require "lib"
local ENV = {
         lib = lib,
         lfs = require "lfs",
}
local test = lib.file.test
local string = string
setmetatable(ENV, {__index = _G})
local fmt, util = lib.fmt, lib.util
local reterr = function(tbl, err)
    local ln = string.match(err, "^.+:([%d]):.*")
    if not ln then return fmt.panic("bug: Unhandled condition.\n") end
    local sp = string.rep(" ", string.len(ln))
    err = string.match(err, "^.+:[%d]:(.*)")
    return fmt.panic("error: %s\n %s |\n %s | %s\n %s |\n", err, sp, ln, tbl[tonumber(ln)], sp)
end
local spath = util.split(script)
package.path = string.format("%s/?.lua;%s/?/init.lua;./?.lua;./?/init.lua", spath, spath)
if not test(script) then
    return fmt.panic("error: problem reading script '%s'.\n", script )
end
local tbl = {}
for ln in io.lines(script) do
    tbl[#tbl + 1] = ln
end
local chunk, err = loadstring(table.concat(tbl, "\n"), script)
if chunk then
    setfenv(chunk, ENV)
    local pr, pe = pcall(chunk)
    if not pr then
        return reterr(tbl, pe)
    end
else
    return reterr(tbl, err)
end
