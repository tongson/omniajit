local lib = require "lib"
local fmt = lib.fmt
local util = lib.util
local exec = require "exec"
local module = {}

local from = function(base, cwd)
    local name = util.random_string(16)
    local cwd = cwd or "."
    local exe = exec.ctx("/usr/bin/buildah")
    exe.errexit = true
    exe("from", "--name", name, base)
    local fn = {}
    fn.run = function(...)
        fmt.print("RUN %s\n", table.concat({...}, " "))
        exe("run", name, "--", ...)
    end
    return fn
end

module.from = from
return module
