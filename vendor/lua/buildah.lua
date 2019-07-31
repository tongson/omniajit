local lib = require "lib"
local util = lib.util
local msg = lib.msg
local exec = require "exec"
local string = string
local sf = string.format
local tm = function() return os.date("%T") end
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
        msg.info(sf("Initializing base image %s...", base))
        name = util.random_string(16)
        exe("from", "--name", name, base)
        msg.ok"Base image pulled."
    else
        msg.ok(sf("Reusing %s.", name))
    end
    local fn = {}
    fn.run = function(...)
        local a = pargs(...)
        msg.info(sf("%s RUN %s\n", tm(), concat(a, " ")))
        exe("run", name, "--", unpack(a))
    end
    fn.apt_get = function(...)
        local a = pargs(...)
        msg.info(sf("%s RUN apt-get %s\n", tm(), concat(a, " ")))
        exe("run", name, "--", "/usr/bin/env", "LC_ALL=C", "DEBIAN_FRONTEND=noninteractive", "apt-get", "-qq",
        "--no-install-recommends", "-o APT::Install-Suggests=0", "-o APT::Get::AutomaticRemove=1", "-o Dpkg::Use-Pty=0",
        "-o Dpkg::Options::='--force-confdef'", "-o Dpkg::Options::='--force-confold'", unpack(a))
    end
    fn.copy = function(src, dest)
        dest = dest or '/'
        msg.info(sf("%s COPY '%s' to '%s'\n", tm(), src, dest))
        exe("copy", name, src, dest)
    end
    fn.clear = function(f)
        msg.info(sf("%s CLEAR %s\n", tm(), f))
        exe("run", name, "--", "/usr/bin/find", f, "-type", "f", "-o", "-type", "s", "-o", "-type", "p", "-ignore_readdir_race", "-delete")
        exe("run", name, "--", "/usr/bin/find", f, "-mindepth", "1", "-type", "d", "-ignore_readdir_race", "-delete")
    end
    fn.mkdir = function(d)
        msg.info(sf("%s MKDIR %s\n", tm(), d))
        exe("run", name, "--", "mkdir", "-p", d)
    end
    fn.rm = function(f)
        msg.info(sf("%s RM %s\n", tm(), f))
        exe("run", name, "--", "rm", "-r", f)
    end
    fn.entrypoint = function(s)
        msg.info(sf("%s ENTRYPOINT %s\n", tm(), s))
        exe("config", "--entrypoint", s, name)
        exe("config", "--cmd", "''", name)
        exe("config", "--stop-signal", "TERM", name)
    end
    fn.push = function(cname, tag)
        msg.info(sf("%s PUSH %s:%s\n", tm(), cname, tag))
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
        msg.ok(sf("Pushed %s:%s", cname, tag))
    end
    return fn
end

module.from = from
return module
