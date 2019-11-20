local lib = require "lib"
local util = lib.util
local msg = lib.msg
local string = string
local exec = lib.exec
local F = string.format
local M = {}

local USER = os.getenv "USER"
local HOME = os.getenv "HOME"

local from = function(base, cwd, name)
    cwd = cwd or "."
    local popen = exec.ctx()
    popen.cwd = cwd
    popen.env = { USER = USER, HOME = HOME }
    popen("buildah rm -a")
    if not name then
        msg.info("Initializing base image %s...", base)
        name = util.random_string(16)
        popen("buildah from --name %s %s", name, base)
        msg.ok"Base image pulled."
    else
        msg.ok(F("Reusing %s.", name))
    end
    local fn = {}
    setmetatable(fn, {__index = function(_, value)
        return rawget(fn, string.lower(value)) or rawget(_G, string.lower(value))
    end})
    fn.run = function(a)
        msg.debug("RUN %s", a)
        popen("buildah run %s -- %s", name, a)
    end
    fn.script = function(a)
        msg.debug("SCRIPT %s", a)
        popen("buildah copy %s %s /%s", name, a, a)
        popen("buildah run %s -- sh /%s", name, a)
        popen("buildah run %s -- rm -f /%s", name, a)
    end
    fn.apt_get = function(a)
        local apt = [[/usr/bin/env LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -qq --no-install-recommends -o APT::Install-Suggests=0 -o APT::Get::AutomaticRemove=1 -o Dpkg::Use-Pty=0 -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold']]
        msg.debug("RUN apt-get %s", a)
        popen("buildah run %s -- %s %s", name, apt, a)
    end
    fn.zypper = function(a)
	local z = [[/usr/bin/zypper --non-interactive --quiet]]
	msg.debug("RUN zypper %s", a)
	popen("buildah run %s -- %s %s", name, z, a)
    end
    fn.copy = function(src, dest)
        dest = dest or '/'
        msg.debug("COPY '%s' to '%s'", src, dest)
        popen("buildah copy %s %s %s", name, src, dest)
    end
    fn.clear = function(d)
        msg.debug("CLEAR %s", d)
        popen("buildah run %s -- /usr/bin/find %s -mindepth 1 -ignore_readdir_race -delete", name, d)
    end
    fn.mkdir = function(d)
        msg.debug("MKDIR %s", d)
        popen("buildah run %s -- mkdir -p %s", name, d)
    end
    fn.rm = function(f)
        msg.debug("RM %s", f)
        popen("buildah run %s -- rm -r %s", name, f)
    end
    fn.entrypoint = function(s)
        msg.debug("ENTRYPOINT %s", s)
        popen("buildah config --entrypoint '%s' %s", s, name)
        popen("buildah config --cmd '' %s", name)
        popen("buildah config --stop-signal TERM %s", name)
    end
    fn.sshd = function(p)
        msg.debug("SSHD localhost:%s", p)
	local s = F('["/usr/sbin/sshd", "-eD", "-oCiphers=aes128-ctr", "-oUseDNS=no", "-oPermitRootLogin=yes", "-oListenAddress=127.0.0.1:%s"]', p)
	popen("buildah config --entrypoint '%s' %s", s, name)
        popen("buildah config --cmd '' %s", name)
        popen("buildah config --stop-signal TERM %s", name)
    end
    fn.dropbear = function(p, old)
        msg.debug("DROPBEAR localhost:%s", p)
        local s
        if old then
            s = F('["/usr/sbin/dropbear", "-b", "/etc/banner", "-FEm", "-p", "127.0.0.1:%s"]', p)
        else
            s = F('["/usr/sbin/dropbear", "-R", "-F", "-E", "-B", "-j", "-k", "-p", "127.0.0.1:%s", "-b", "/etc/banner"]', p)
        end
        popen("buildah config --entrypoint '%s' %s", s, name)
        popen("buildah config --cmd '' %s", name)
        popen("buildah config --stop-signal TERM %s", name)
    end
    fn.write = function(cname)
        msg.debug("WRITE containers-storage:%s", cname)
        local tmpname = F("%s.%s", cname, util.random_string(16))
        popen("buildah commit --rm --squash %s dir:%s", name, tmpname)
        popen([[mv $(find %s -maxdepth 1 -type f -exec file {} \+ | awk -F\: '/archive/{print $1}') %s.tar]], tmpname, tmpname)
        popen("mkdir %s", cname)
        popen(F("tar -C %s -xvf %s.tar", cname, tmpname))
        os.execute(F("rm -f %s.tar", tmpname))
        os.execute(F("rm -rf %s", cname))
        msg.ok("Wrote dir:%s", cname)
    end
    fn.commit = function(cname)
        msg.debug("COMMIT containers-storage:%s", cname)
        local tmpname = F("%s.%s", cname, util.random_string(16))
        popen("buildah commit --rm --squash %s containers-storage:%s", name, tmpname)
        msg.ok("Committed %s", cname)
    end
    fn.archive = function(cname)
        msg.debug("ARCHIVE oci:%s", cname)
        popen("buildah commit --rm --squash %s oci-archive:%s", name, cname)
        msg.ok("OCI image %s", cname)
    end
    fn.containers_storage = function(cname)
        msg.debug("CONTAINERS-STORAGE %s", cname)
        popen("buildah commit --rm --squash %s containers-storage:%s", name, cname)
        msg.ok("Committed image %s", cname)
    end
    fn.storage = fn.containers_storage
    fn.push = function(repo, cname, tag)
        msg.debug("PUSH %s:%s", cname, tag)
        local tmpname = F("%s.%s", cname, util.random_string(16))
        popen("buildah commit --format docker --squash --rm %s dir:%s", name, tmpname)
        local _, r = popen("/usr/bin/aws ecr get-login")
        local ecrpass = string.match(r.output[1], "^docker%slogin%s%-u%sAWS%s%-p%s([A-Za-z0-9=]+)%s.*$")
        popen("/usr/bin/skopeo copy --dcreds AWS:%s dir:%s %s/%s:%s", ecrpass, tmpname, repo, cname, tag)
        popen("/usr/bin/skopeo copy dir:%s containers-storage:%s:%s", tmpname, cname, tag)
        os.execute(F("rm -r %s/%s", cwd, tmpname))
        msg.ok("Pushed %s:%s", cname, tag)
    end
    fn.cache = function(ssh, cname, tag)
        msg.debug("CACHE %s:%s", cname, tag)
        local tmpname = F("%s.%s", cname, util.random_string(16))
        popen("mkdir -p %s/%s", tmpname, cname)
        popen("/usr/bin/skopeo copy containers-storage:%s:%s oci-archive:%s/%s/%s", cname, tag, tmpname, cname, tag)
        popen("/usr/bin/sha256sum %s/%s/%s > %s/%s/%s.sha256", tmpname, cname, tag, tmpname, cname, tag)
        popen("XZ_OPT=-T0 /usr/bin/tar -C %s -cJf IMAGE.tar.xz %s", tmpname, cname)
        popen("/usr/bin/scp IMAGE.tar.xz %s/%s/%s", ssh, cname, tag)
    end
    return fn
end

M.from = from
return M
