local lib = require "lib"
local fmt = lib.fmt
local util = lib.util
local exec = require "exec"
local cc = table.concat
local module = {}

local from = function(base, cwd)
    local name = util.random_string(16)
    local cwd = cwd or "."
    local exe = exec.ctx("/usr/bin/buildah")
    exe.errexit = true
    exe("from", "--name", name, base)
    local fn = {}
    fn.run = function(...)
        fmt.print("RUN %s\n", cc({...}, " "))
        exe("run", name, "--", ...)
    end
    fn.apt_get = function(...)
        fmt.print("RUN apt-get %s\n", cc({...}, " "))
        exe("run", name, "--", "/usr/bin/env", "LC_ALL=C", "DEBIAN_FRONTEND=noninteractive", "apt-get", "-qq",
        "--no-install-recommends", "-o APT::Install-Suggests=0", "-o APT::Get::AutomaticRemove=1", "-o Dpkg::Use-Pty=0",
        "-o Dpkg::Options::='--force-confdef'", "-o Dpkg::Options::='--force-confold'", ...)
    end
    return fn
end

module.from = from
return module
