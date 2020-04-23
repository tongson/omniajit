-- Requires buildah, skopeo
local lib = require "lib"
local util = lib.util
local msg = lib.msg
local string = string
local exec = lib.exec
local F = string.format
local M = {}

local USER = os.getenv "USER"
local HOME = os.getenv "HOME"
--++ # BUILDAH MODULE
--++ ## buildah.from(base, main, [cwd])
--++ Returns a function that executes the *main* `buildah` routine containing the `buildah` DSL.
--++
--++ *base* is a required string indicating the container image to base from. (e.g. `docker://docker.io/library/debian:stable-slim`)
--++ *cwd* is an optional string that sets the current working directory for the subsequent `buildah` commands.
--++
--++ # DSL
local from = function(base, fn, cwd, name)
    cwd = cwd or "."
    local popen = exec.ctx()
    popen.cwd = cwd
    popen.env = { USER = USER, HOME = HOME }
    if not name then
        popen("buildah rm -a")
        msg.info("Initializing base image %s...", base)
        name = util.random_string(16)
        popen("buildah from --name %s %s", name, base)
        msg.ok"Base image pulled."
    else
        msg.ok(F("Reusing %s.", name))
    end
    local env = {}
    setmetatable(env, {__index = function(_, value)
        return rawget(env, value) or rawget(_G, value)
    end})
    --++ ### RUN(command)
    --++ Runs the *command* within the container.
    --++
    env.RUN = function(a)
        msg.debug("RUN %s", a)
        popen("buildah run %s -- %s", name, a)
    end
    --++ ### SCRIPT(file)
    --++ Runs the *file* within the container as a shell script.
    --++
    env.SCRIPT = function(a)
        msg.debug("SCRIPT %s", a)
        popen("buildah copy %s %s /%s", name, a, a)
        popen("buildah run %s -- sh /%s", name, a)
        popen("buildah run %s -- rm -f /%s", name, a)
    end
    --++ ### APT_GET(arguments)
    --++ Wraps the /Debian/ `apt-get` command.
    --++ Usually used installing packages (.e.g. `APT_GET install build-essential`)
    --++
    env.APT_GET = function(a)
        local apt = [[/usr/bin/env LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -qq --no-install-recommends -o APT::Install-Suggests=0 -o APT::Get::AutomaticRemove=1 -o Dpkg::Use-Pty=0 -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' -o DPkg::options::='--force-unsafe-io']]
        msg.debug("RUN apt-get %s", a)
        popen("buildah run %s -- %s %s", name, apt, a)
    end
    --++ ### ZYPPER(arguments)
    --++ Wraps the /openSUSE/ `zypper` command.
    --++
    env.ZYPPER = function(a)
	local z = [[/usr/bin/zypper --non-interactive --quiet]]
	msg.debug("RUN zypper %s", a)
	popen("buildah run %s -- %s %s", name, z, a)
    end
    --++ ### COPY(source, destination)
    --++ Copies the *source* file from the current directory to the the optional argument *destination*.
    --++ Writes to the root('/') directory if *destination* is not given.
    --++
    env.COPY = function(src, dest)
        dest = dest or '/'
        msg.debug("COPY '%s' to '%s'", src, dest)
        popen("buildah copy %s %s %s", name, src, dest)
    end
    --++ ### CLEAR(directory)
    --++ Deletes all files and directories one level down from the string *directory*.
    --++ If a list(table) is given, then each directory(string) is cleared.
    --++
    env.CLEAR = function(d)
        if type(d) == "table" and next(d) then
            msg.debug("CLEAR (table)")
            for _, r in ipairs(d) do
                popen("buildah run %s -- /usr/bin/find %s -mindepth 1 -ignore_readdir_race -delete", name, r)
            end
        else
            msg.debug("CLEAR %s", d)
            popen("buildah run %s -- /usr/bin/find %s -mindepth 1 -ignore_readdir_race -delete", name, d)
        end
    end
    --++ ### MKDIR(directory)
    --++ Create directory within container.
    --++
    env.MKDIR = function(d)
        msg.debug("MKDIR %s", d)
        popen("buildah run %s -- mkdir -p %s", name, d)
    end
    --++ ### RM(file)
    --++ Deletes the string *file*.
    --++ If a list(table) is given, then each file(string) is deleted.
    --++
    env.RM = function(f)
        if type(f) == "table" and next(f) then
            msg.debug("RM (table)")
            for _, r in ipairs(f) do
                popen("buildah run %s -- rm -rf %s", name, r)
            end
        else
            msg.debug("RM %s", f)
            popen("buildah run %s -- rm -rf %s", name, f)
        end
    end
    --++ ### ENTRYPOINT(executable)
    --++ Sets the container entrypoint.
    --++ NOTE: Only accepts a single entrypoint item, usually the executable.
    --++
    env.ENTRYPOINT = function(s)
        msg.debug("ENTRYPOINT %s", s)
        popen("buildah config --entrypoint '[\"%s\"]' %s", s, name)
        popen("buildah config --cmd '' %s", name)
        popen("buildah config --stop-signal TERM %s", name)
    end
    --++ ### SSHD(argument)
    --++ Sets the container entrypoint to `sshd`.
    --++ If *argument* is a string, it will be used as the `sshd_config` by `sshd`.
    --++ If *argument* is a number, then it is considered the localhost(127.0.0.1) port number `sshd` listens to.
    --++
    env.SSHD = function(p)
        local s
        if type(p) == "string" then
            msg.debug("SSHD file:%s", p)
            popen("buildah copy %s %s %s", name, p, "/etc/ssh/sshd_config")
            popen("buildah run %s -- %s", name, "chmod 0640 /etc/ssh/sshd_config")
            s = '["/usr/sbin/sshd", "-eD"]'
        elseif type(p) == "number" then
            p = tostring(p)
            msg.debug("SSHD localhost:%p", p)
	    s = F('["/usr/sbin/sshd", "-eD", "-oCiphers=aes128-ctr", "-oUseDNS=no", "-oPermitRootLogin=yes", "-oListenAddress=127.0.0.1:%s"]', p)
        end
	popen("buildah config --entrypoint '%s' %s", s, name)
        popen("buildah config --cmd '' %s", name)
        popen("buildah config --stop-signal TERM %s", name)
    end
    --++ ### DROPBEAR(port)
    --++ Sets the container entrypoint to `dropbear`.
    --++ The argument *port* is the localhost(127.0.0.1) port number `dropbear` listens to.
    --++
    env.DROPBEAR = function(p, old)
        p = tostring(p)
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
    --++ ### WRITE(directory)
    --++ Writes the container image to *directory*.
    --++ > NOTE: This finalizes the `buildah` run.
    --++
    env.WRITE = function(cname)
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
    --++ ### ARCHIVE(name)
    --++ Saves the container as an `oci-archive` with filename *name*.
    --++ > NOTE: This finalizes the `buildah` run.
    --++
    env.ARCHIVE = function(cname)
        msg.debug("ARCHIVE oci:%s", cname)
        popen("buildah commit --rm --squash %s oci-archive:%s", name, cname)
        msg.ok("OCI image %s", cname)
    end
    --++ ### CONTAINERS_STORAGE(name)
    --++ Saves the container to `containers-storage`.
    --++ Aliases: STORAGE, COMMIT
    --++ > NOTE: This finalizes the `buildah` run.
    --++
    env.CONTAINERS_STORAGE = function(cname, tag)
        tag = tag or "latest"
        msg.debug("CONTAINERS-STORAGE %s:%s", cname, tag)
        popen("buildah commit --rm --squash %s containers-storage:%s:%s", name, cname, tag)
        msg.ok("Committed image %s", cname)
    end
    env.STORAGE = env.CONTAINERS_STORAGE
    env.COMMIT = env.CONTAINERS_STORAGE
    --++ ### ECR_PUSH(repository, name, tag)
    --++ Push container to AWS ECR under *name:tag*.
    --++ Requires `aws-cli` and AWS ECR credentials.
    --++ > NOTE: This finalizes the `buildah` run.
    --++
    env.ECR_PUSH = function(repo, cname, tag)
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
    --++ ### LOCAL_PUSH(repository, credentials, name, tag)
    --++ Push container to specified docker repository under *name:tag*
    --++ Only supports docker repository basic authentication.
    --++ Alias: PUSH
    --++ > NOTE: This finalizes the `buildah` run.
    --++
    env.LOCAL_PUSH = function(repo, creds, cname, tag)
        msg.debug("PUSH %s:%s", cname, tag)
        local tmpname = F("%s.%s", cname, util.random_string(16))
        popen("buildah commit --format docker --squash --rm %s dir:%s", name, tmpname)
        popen("/usr/bin/skopeo copy --dcreds %s dir:%s docker://%s/%s:%s", creds, tmpname, repo, cname, tag)
        popen("/usr/bin/skopeo copy dir:%s containers-storage:%s:%s", tmpname, cname, tag)
        os.execute(F("rm -r %s/%s", cwd, tmpname))
        msg.ok("Pushed %s:%s", cname, tag)
    end
    env.PUSH = env.LOCAL_PUSH
    --++ ### XPUSH(repository, credentials, name, tag)
    --++ Push container to specified docker repository under *name:tag*
    --++ Only supports docker repository basic authentication.
    --++ Alias: PUSH
    --++ > NOTE: This finalizes the `buildah` run.
    --++
    env.XPUSH = function(repo, creds, cname, tag, ...)
        msg.debug("PUSH %s:%s", cname, tag)
        local tmpname = F("%s.%s", cname, util.random_string(16))
        popen("buildah commit --format docker --squash --rm %s dir:%s", name, tmpname)
        popen("/usr/bin/skopeo copy --dest-tls-verify=false --dest-creds %s dir:%s docker://%s/%s:%s", creds, tmpname, repo, cname, tag)
        for _, newtag in ipairs{...} do
            popen("/usr/bin/skopeo copy --src-tls-verify=false --dest-tls-verify=false --src-creds %s --dest-creds %s docker://%s/%s:%s docker://%s/%s:%s", creds, creds, repo, cname, tag, repo, cname, newtag)
        end
        os.execute(F("rm -r %s/%s", cwd, tmpname))
        msg.ok("Pushed %s:%s", cname, tag)
    end
    -- ### CACHE(host, name, src, dest)
    -- Copy container image from `containers-storate` as `oci-archive` via `scp` to *host*.
    -- *src* and *dest* are optional image tags. *src* defaults to "latest" and *dest* defaults to *src*.
    env.CACHE = function(ssh, cname, stag, dtag)
        stag = stag or "latest"
        dtag = dtag or stag
        msg.debug("CACHE %s:%s -> %s:%s", cname, stag, cname, dtag)
        local tmpname = F("%s.%s", cname, util.random_string(16))
        popen("mkdir -p %s/%s", tmpname, cname)
        popen("/usr/bin/skopeo copy containers-storage:%s:%s oci-archive:%s/%s/%s", cname, stag, tmpname, cname, dtag)
        popen("cd %s; /usr/bin/sha256sum %s/%s > %s/%s.sha256", tmpname, cname, dtag, cname, dtag)
        popen("XZ_OPT=-T0 /usr/bin/tar -C %s -cJf IMAGE.tar.xz %s", tmpname, cname)
        popen("/usr/bin/scp IMAGE.tar.xz %s/%s/%s", ssh, cname, dtag)
        popen("rm IMAGE.tar.xz")
        os.execute(F("rm -r %s/%s", cwd, tmpname))
    end
    setfenv(2, env)
end

M.from = from
return M
