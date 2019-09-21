local script = arg[1]
local lib = require "lib"
local func = lib.func
local argv = {}
argv[0] = arg[1]
if #arg > 1 then
    for i = 2, #arg do
        argv[i-1] = arg[i]
    end
end
rawset(_G, "arg", argv)
local ENV = {
    lib = lib,
    argparse = require "argparse",
    lfs = require "lfs",
}
local string = string
setmetatable(ENV, {__index = _G})
local fmt, util = lib.fmt, lib.util
local spath = util.split(script)
package.path = string.format("%s/?.lua;%s/?/init.lua;./?.lua;./?/init.lua", spath, spath)
func.try(fmt.panic)(lib.file.test(script), "error: problem reading script '%s'.\n", script)
do
    local tbl = {}
    for ln in io.lines(script) do
        tbl[#tbl + 1] = ln
    end
    local chunk, err = loadstring(table.concat(tbl, "\n"), script)
    local run = func.try(function(rt, re)
        local ln = string.match(re, "^.+:([%d]):.*")
        if not ln then
            fmt.warn("bug: Unhandled condition or error string.\n")
            fmt.warn("error:\n  %s\n", re)
            return fmt.panic("Exiting.\n")
        end
        local sp = string.rep(" ", string.len(ln))
        re = string.match(re, "^.+:[%d]:(.*)")
        return fmt.panic("error: %s\n %s |\n %s | %s\n %s |\n", re, sp, ln, rt[tonumber(ln)], sp)
    end)
    run(chunk, tbl, err)
    setfenv(chunk, ENV)
    local pr, pe = pcall(chunk)
    run(pr, tbl, pe)
end
