local lib = require "lib"
local fmt = lib.fmt
local util = lib.util
local msg = lib.msg
local string = string
local exec = lib.exec
local F = string.format
local M = {}

local from = function(base, cwd, name)
    cwd = cwd or "."
    local popen = exec.ctx()
    if not name then
        msg.info(F("Initializing base image %s...", base))
        name = util.random_string(16)
        popen("buildah from --name %s %s", name, base)
        msg.ok"Base image pulled."
    else
        msg.ok(F("Reusing %s.", name))
    end
    local fn = {}
    fn.run = function(a)
        msg.debug(F("RUN %s", a))
        popen("buildah run %s -- %s", name, a)
    end
    fn.script = function(a)
        msg.debug(F("SCRIPT %s", a))
        popen.cwd = cwd
        popen("buildah copy %s %s /%s", name, a, a)
        popen("buildah run %s -- sh /%s", name, a)
        popen("buildah run %s -- rm -f /%s", name, a)
    end
    fn.apt_get = function(a)
        local apt = [[/usr/bin/env LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -qq --no-install-recommends -o APT::Install-Suggests=0 -o APT::Get::AutomaticRemove=1 -o Dpkg::Use-Pty=0 -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold']]
        msg.debug(F("RUN apt-get %s", a))
        popen("buildah run %s -- %s %s", name, apt, a)
    end
    fn.zypper = function(a)
	local z = [[/usr/bin/zypper --non-interactive --quiet]]
	msg.debug(F("RUN zypper %s", a))
	popen("buildah run %s -- %s %s", name, z, a)
    end
    fn.copy = function(src, dest)
        dest = dest or '/'
        msg.debug(F("COPY '%s' to '%s'", src, dest))
        popen("buildah copy %s %s %s", name, src, dest)
    end
    fn.clear = function(d)
        msg.debug(F("CLEAR %s", d))
        popen("buildah run %s -- /usr/bin/find %s -mindepth 1 -ignore_readdir_race -delete", name, d)
    end
    fn.mkdir = function(d)
        msg.debug(F("MKDIR %s", d))
        popen("buildah run %s -- mkdir -p %s", name, d)
    end
    fn.rm = function(f)
        msg.debug(F("RM %s", f))
        popen("buildah run %s -- rm -r %s", name, f)
    end
    fn.entrypoint = function(s)
        msg.debug(F("ENTRYPOINT %s", s))
        popen("buildah config --entrypoint '%s' %s", s, name)
        popen("buildah config --cmd '' %s", name)
        popen("buildah config --stop-signal TERM %s", name)
    end
    fn.sshd = function(p)
        msg.debug(F("SSHD localhost:%s", p))
	local s = F('["/usr/sbin/sshd", "-eD", "-oCiphers=aes128-ctr", "-oUseDNS=no", "-oPermitRootLogin=yes", "-oListenAddress=127.0.0.1:%s"]', p)
	popen("buildah config --entrypoint '%s' %s", s, name)
        popen("buildah config --cmd '' %s", name)
        popen("buildah config --stop-signal TERM %s", name)
    end
    fn.dropbear = function(p)
        msg.debug(F("DROPBEAR localhost:%s", p))
	local s = F('["/usr/sbin/dropbear", "-b", "/etc/banner", "-FEm", "-p", "127.0.0.1:%s"]', p)
	popen("buildah config --entrypoint '%s' %s", s, name)
        popen("buildah config --cmd '' %s", name)
        popen("buildah config --stop-signal TERM %s", name)
    end
    fn.write = function(cname)
        msg.debug(F("WRITE containers-storage:%s", cname))
        local tmpname = F("%s.%s", cname, util.random_string(16))
        popen("buildah commit --rm --squash %s dir:%s", name, tmpname)
        popen([[mv $(find %s -maxdepth 1 -type f -exec file {} \+ | awk -F\: '/archive/{print $1}') %s.tar]], tmpname, tmpname)
        popen("mkdir %s", cname)
        popen(F("tar -C %s -xvf %s.tar", cname, tmpname))
        os.execute(F("rm -f %s.tar", tmpname))
        os.execute(F("rm -rf %s", cname))
        msg.ok(F("Wrote dir:%s", cname))
    end
    fn.commit = function(cname)
        msg.debug(F("COMMIT containers-storage:%s", cname))
        local tmpname = F("%s.%s", cname, util.random_string(16))
        popen("buildah commit --rm --squash %s containers-storage:%s", name, tmpname)
        msg.ok(F("Committed %s", cname))
    end
    fn.oci = function(cname)
        msg.debug(F("OCI oci:%s", cname))
        popen("buildah commit --rm --squash %s oci-archive:%s", name, cname)
        msg.ok(F("OCI image %s", cname))
    end
    fn.containers_storage = function(cname)
        msg.debug(F("CONTAINERS-STORAGE %s", cname))
        popen("buildah commit --rm --squash %s containers-storage:%s", name, cname)
        msg.ok(F("Committed image %s", cname))
    end
    fn.push = function(repo, cname, tag)
        msg.debug(F("PUSH %s:%s", cname, tag))
        local tmpname = F("%s.%s", cname, util.random_string(16))
        popen("buildah commit --format docker --squash --rm %s dir:%s", name, tmpname)
        local r = popen("/usr/bin/aws ecr get-login")
        local ecrpass = string.match(r.output[1], "^docker%slogin%s%-u%sAWS%s%-p%s([A-Za-z0-9=]+)%s.*$")
        local repo = "docker://872492578903.dkr.ecr.ap-southeast-1.amazonaws.com"
        popen("/usr/bin/skopeo copy --dcreds AWS:%s dir:%s %s/%s:%s", ecrpass, tmpname, repo, cname, tag)
        popen("/usr/bin/skopeo copy dir:%s containers-storage:%s:%s", tmpname, cname, tag)
        os.execute("rm -r "..tmpname)
        msg.ok(F("Pushed %s:%s", cname, tag))
    end
    return fn
end

M.from = from
return M
