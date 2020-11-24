exec = require "exec"
sed = exec.ctx("/bin/sed")
sed.stdin ="tt"
e, r = sed("s|tt|gg|")
print(e)
print(r.stdout[1])
print(r.error)
print(r.code)
