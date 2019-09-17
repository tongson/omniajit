local lib = require "lib"
local fmt = lib.fmt
local util = lib.util
local msg = lib.msg
local string = string
local F = string.format
local module = {}

local popen = function(str, cwd)
  local line = str
  local ignore = false
  if string.sub(str, 1, 1) == "-" then
      ignore = true
      str = string.sub(str, 2)
  end
  local shoptions = [[
  set -o noglob -o errexit -o nounset -o pipefail
  ]]
  local header = [[
  unset IFS
  export LC_ALL=C
  export PATH=/bin:/sbin:/usr/bin:/usr/sbin
  exec 2>&1
  ]]
  if not ignore then
    header = string.format("%s%s", shoptions, header)
  end
  if cwd then
    str = string.format("%scd %s\n%s", header, cwd, str)
  else
    str = string.format("%s%s", header, str)
  end
  local R = {}
  local pipe = io.popen(str, "r")
  io.flush(pipe)
  R.output = {}
  for ln in pipe:lines() do
    R.output[#R.output + 1] = ln
  end
  local _, status, code = io.close(pipe)
  if next(R.output) then
    print(table.concat(R.output, "\n"))
  end
  if code ~= 0 and not ignore then
      return fmt.panic("<%s:%s> %s\n  -- OUTPUT --\n%s\n", status, code, line, table.concat(R.output, "\n"))
  end
  return R
end

local from = function(base, cwd, name)
    cwd = cwd or "."
    if not name then
        msg.info(F("Initializing base image %s...", base))
        name = util.random_string(16)
        popen(F("buildah from --name %s %s", name, base))
        msg.ok"Base image pulled."
    else
        msg.ok(F("Reusing %s.", name))
    end
    local fn = {}
    fn.run = function(a, i)
        msg.debug(F("RUN %s", a))
        if not i then
            popen(F("buildah run %s -- %s", name, a))
        else
            popen(F("-buildah run %s -- %s", name, a))
        end
    end
    fn.script = function(a)
        msg.debug(F("SCRIPT %s", a))
        popen(F("buildah copy %s %s /%s", name, a, a), cwd)
        popen(F("buildah run %s -- sh /%s", name, a))
        popen(F("buildah run %s -- rm -f /%s", name, a))
    end
    fn.apt_get = function(a)
        local apt = [[/usr/bin/env LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -qq --no-install-recommends -o APT::Install-Suggests=0 -o APT::Get::AutomaticRemove=1 -o Dpkg::Use-Pty=0 -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold']]
        msg.debug(F("RUN apt-get %s", a))
        popen(F("buildah run %s -- %s %s", name, apt, a))
    end
    fn.zypper = function(a)
	local z = [[/usr/bin/zypper --non-interactive --quiet]]
	msg.debug(F("RUN zypper %s", a))
	popen(F("buildah run %s -- %s %s", name, z, a))
    end
    fn.copy = function(src, dest)
        dest = dest or '/'
        msg.debug(F("COPY '%s' to '%s'", src, dest))
        popen(F("buildah copy %s %s %s", name, src, dest), cwd)
    end
    fn.clear = function(d)
        msg.debug(F("CLEAR %s", d))
        popen(F("buildah run %s -- /usr/bin/find %s -mindepth 1 -ignore_readdir_race -delete", name, d))
    end
    fn.mkdir = function(d)
        msg.debug(F("MKDIR %s", d))
        popen(F("buildah run %s -- mkdir -p %s", name, d))
    end
    fn.rm = function(f)
        msg.debug(F("RM %s", f))
        popen(F("buildah run %s -- rm -r %s", name, f))
    end
    fn.entrypoint = function(s)
        msg.debug(F("ENTRYPOINT %s", s))
        popen(F("buildah config --entrypoint '%s' %s", s, name))
        popen(F("buildah config --cmd '' %s", name))
        popen(F("buildah config --stop-signal TERM %s", name))
    end
    fn.sshd = function(p)
        msg.debug(F("SSHD %s", p))
	local s = F('["/usr/sbin/sshd", "-D", "-oCiphers=aes128-ctr", "-oUseDNS=no", "-oPermitRootLogin=yes", "-oListenAddress=127.0.0.1", "-p%s"]', p)
	popen(F("buildah config --entrypoint '%s' %s", s, name))
        popen(F("buildah config --cmd '' %s", name))
        popen(F("buildah config --stop-signal TERM %s", name))
    end
    fn.write = function(cname)
        msg.debug(F("WRITE containers-storage:%s", cname))
        local tmpname = string.format("%s.%s", cname, util.random_string(16))
        popen(F("buildah commit --rm --squash %s dir:%s", name, tmpname))
        popen(F([[mv $(find %s -maxdepth 1 -type f -exec file {} \+ | awk -F\: '/archive/{print $1}') %s.tar]], tmpname, tmpname))
        popen(F("mkdir %s", cname))
        popen(F("tar -C %s -xvf %s.tar", cname, tmpname))
        os.execute(F("rm -f %s.tar", tmpname))
        os.execute(F("rm -rf %s", cname))
        msg.ok(F("Wrote dir:%s", cname))
    end
    fn.commit = function(cname)
        msg.debug(F("COMMIT containers-storage:%s", cname))
        local tmpname = string.format("%s.%s", cname, util.random_string(16))
        popen(F("buildah commit --rm --squash %s containers-storage:%s", name, tmpname))
        msg.ok(F("Committed %s", cname))
    end
    fn.oci = function(cname)
        msg.debug(F("OCI oci:%s", cname))
        popen(F("buildah commit --rm --squash %s oci-archive:%s", name, cname))
        msg.ok(F("OCI image %s", cname))
    end
    fn.push = function(repo, cname, tag)
        msg.debug(F("PUSH %s:%s", cname, tag))
        local tmpname = string.format("%s.%s", cname, util.random_string(16))
        popen(F("buildah commit --format docker --squash --rm %s dir:%s", name, tmpname))
        local r = popen("/usr/bin/aws ecr get-login")
        local ecrpass = string.match(r.output[1], "^docker%slogin%s%-u%sAWS%s%-p%s([A-Za-z0-9=]+)%s.*$")
        local repo = "docker://872492578903.dkr.ecr.ap-southeast-1.amazonaws.com"
        popen(F("/usr/bin/skopeo copy --dcreds AWS:%s dir:%s %s/%s:%s", ecrpass, tmpname, repo, cname, tag))
        popen(F("/usr/bin/skopeo copy dir:%s containers-storage:%s:%s", tmpname, cname, tag))
        os.execute("rm -r "..tmpname)
        msg.ok(F("Pushed %s:%s", cname, tag))
    end
    return fn
end

module.from = from
return module
