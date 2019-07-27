local lib = require "lib"
local fmt = lib.fmt
local util = lib.util
local exec = require "exec"
local concat, unpack = table.concat, table.unpack
local module = {}

local pargs = function(...)
    local args = {}
    local n = select("#", ...)
    if n == 1 then
        for a in string.gmatch(..., "%S+") do
            args[#args+1] = a
        end
    elseif n > 1 then
        for _, a in ipairs({...}) do
            args[#args+1] = a
        end
    else
        return
    end
    return args
end

local from = function(base, cwd)
    local name = util.random_string(16)
    local cwd = cwd or "."
    local exe = exec.ctx("/usr/bin/buildah")
    exe.errexit = true
    exe("from", "--name", name, base)
    local fn = {}
    fn.run = function(...)
        local a = pargs(...)
        fmt.print("RUN %s\n", concat(a, " "))
        exe("run", name, "--", unpack(a))
    end
    fn.apt_get = function(...)
        local a = pargs(...)
        fmt.print("RUN apt-get %s\n", concat(a, " "))
        exe("run", name, "--", "/usr/bin/env", "LC_ALL=C", "DEBIAN_FRONTEND=noninteractive", "apt-get", "-qq",
        "--no-install-recommends", "-o APT::Install-Suggests=0", "-o APT::Get::AutomaticRemove=1", "-o Dpkg::Use-Pty=0",
        "-o Dpkg::Options::='--force-confdef'", "-o Dpkg::Options::='--force-confold'", unpack(a))
    end
    return fn
end

module.from = from
return module
