local lib = require "lib"
local fmt = lib.fmt
local util = lib.util
local exec = require "exec"
local string = string
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

local from = function(base, cwd, name)
    local exe = exec.ctx("/usr/bin/buildah")
    exe.errexit = true
    exe.cwd = cwd or "."
    if not name then
        name = util.random_string(16)
        exe("from", "--name", name, base)
    end
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
    fn.copy = function(src, dest)
        dest = dest or '/'
        fmt.print("COPY '%s' to '%s'\n", src, dest)
        exe("copy", name, src, dest)
    end
    fn.clear = function(f)
        fmt.print("CLEAR %s\n", f)
        exe("run", name, "--", "/usr/bin/find", f, "-type", "f", "-o", "-type", "s", "-o", "-type", "p", "-ignore_readdir_race", "-delete")
        exe("run", name, "--", "/usr/bin/find", f, "-mindepth", "1", "-type", "d", "-ignore_readdir_race", "-delete")
    end
    fn.mkdir = function(d)
        fmt.print("MKDIR %s\n", d)
        exe("run", name, "--", "mkdir", "-p", d)
    end
    fn.entrypoint = function(s)
        fmt.print("ENTRYPOINT %s\n", s)
        exe("config", "--entrypoint", s, name)
        exe("config", "--cmd", "''", name)
        exe("config", "--stop-signal", "TERM", name)
    end
    fn.push = function(cname, tag)
        fmt.print("PUSH %s:%s\n", cname, tag)
        local tmpname = string.format("%s.%s", cname, util.random_string(16))
        exe("commit", "--format", "docker", "--squash", "--rm", name, "dir:"..tmpname)
        local awscli = exec.ctx("/usr/bin/aws")
        awscli.errexit = true
        local _, r = awscli("ecr", "get-login")
        local ecrpass = string.match(r.stdout[1], "^docker%slogin%s%-u%sAWS%s%-p%s(%w+)%s.*$")
        local skopeo = exec.ctx("/usr/bin/skopeo")
        skopeo.errexit = true
        skopeo.cwd = cwd or "."
        skopeo("copy", "--dcreds", "AWS:"..ecrpass, "dir:"..tmpname, "docker://872492578903.dkr.ecr.ap-southeast-1.amazonaws.com/"..cname..":"..tag)
        skopeo("copy", "dir:"..tmpname, "containers-storage:"..cname..":"..tag)
        os.execute("rm -r "..cwd.."/"..tmpname)
    end
    return fn
end

module.from = from
return module
