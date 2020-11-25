local panic = function(str, ...)
  local o = io.output()
  io.output(io.stderr)
  io.stdout:write(string.format(str, ...))
  io.output(o)
  io.stdout:flush()
  os.exit(1)
end
local ffi = require "ffi"
local ffiext = require "ffi_ext"
local int = ffi.typeof'int[?]'
local C = ffi.C
local exec = {}
ffi.cdef([[
void _exit(int status);
typedef int32_t pid_t;
pid_t fork(void);
pid_t waitpid(pid_t pid, int *status, int options);
int open(const char *pathname, int flags, int mode);
int close(int fd);
int dup2(int oldfd, int newfd);
int setenv(const char*, const char*, int);
int execvp(const char *file, char *const argv[]);
int chdir(const char *);
int pipe(int fd[2]);
typedef long unsigned int size_t;
typedef long signed int ssize_t;
ssize_t read(int, void *, size_t);
ssize_t write(int, const void *, size_t);
int fcntl(int, int, ...);
]])
local STDIN = 0
local STDOUT = 1
local STDERR = 2
local dup2 = ffiext.retry(C.dup2)
local write = ffiext.retry(C.write)
local execvp = ffiext.retry(C.execvp)
local fcntl = ffiext.retry(C.fcntl)
local fork = ffiext.retry(C.fork)
local waitpid = ffiext.retry(C.waitpid)
local read = ffiext.retry(C.read)
local strerror = ffiext.strerror
local open = ffiext.open
local errno = ffi.errno
-- dest should be either 0 or 1 (STDOUT or STDERR)
local redirect = function(io_or_filename, dest_fd)
  if io_or_filename == nil then return true end
  -- first check for regular
  if (io_or_filename == io.stdout or io_or_filename == STDOUT) and dest_fd ~= STDOUT then
    local r, e = dup2(STDERR, STDOUT)
    if r == -1 then return nil, strerror(e, "dup2(2) failed") end
  elseif (io_or_filename == io.stderr or io_or_filename == STDERR) and dest_fd ~= STDERR then
    local r, e = dup2(STDOUT, STDERR)
    if r == -1 then return nil, strerror(e, "dup2(2) failed") end
    -- otherwise handle file-based redirection
  else
    local fd, r, e
    fd, e = open(io_or_filename)
    if fd == -1 then return nil, strerror(e, "open(2) failed") end
    r, e = dup2(fd, dest_fd)
    if r == -1 then
      C.close(fd)
      return nil, strerror(e, "dup2(2) failed")
    end
    C.close(fd)
  end
  return true
end

exec.spawn = function (exe, args, env, cwd, stdin, stdout, stderr, ignore, errexit)
  --[[
    INPUT
      exe: program or executable (string)
      args: arguments to program (table)
      env: environment variables when running program (table)
      cwd: current working directory before running program (string)
      stdin: STDIN input to program (string)
      stdout: file to redirect STDOUT stream to (string)
      stderr: file to redirect STDERR stream to (string)
      ignore: when not nil or false, ignores the return value of the program (string)
      errexit: panic when error is encountered (boolean)

    OUTPUT
      {
        stdout: "STDOUT (string)",
        stderr: "STDERR (string)",
        code: "return code (number)",
        error: "error (string)"
      }
  ]]
  args = args or {}
  local R = {
    stdout = {},
    stderr = {}
  }
  local ret
  local p_stdin = ffi.new("int[2]")
  local p_stdout = ffi.new("int[2]")
  local p_stderr = ffi.new("int[2]")
  local p_errno = ffi.new("int[2]")
  if C.pipe(p_stdin) == -1 then
     R.error = strerror(errno(), "pipe(2) for STDIN failed")
     return nil, R
  end
  if C.pipe(p_stdout) == -1 then
     R.error = strerror(errno(), "pipe(2) for STDOUT failed")
     return nil, R
  end
  if C.pipe(p_stderr) == -1 then
     R.error = strerror(errno(), "pipe(2) for STDERR failed")
     return nil, R
  end
  if C.pipe(p_errno) == -1 then
     R.error = strerror(errno(), "pipe(2) for errno pipe failed")
     return nil, R
  end

  local F_GETFD = 1
  local F_SETFD = 2
  local FD_CLOEXEC = 1
  local flags = fcntl(p_errno[1], F_GETFD)
  local flags = bit.bor(flags, FD_CLOEXEC)
  if fcntl(p_errno[1], F_SETFD, ffi.cast('int', flags)) ~= 0 then
    R.error = strerror(errno(), "fcntl(2) for errno pipe failed")
    return nil, R
  end

  local pid = fork()
  if pid < 0 then
    R.error = strerror(errno(), "fork(2) failed")
    return nil, R
  elseif pid == 0 then -- child process
    C.close(p_stdin[1])
    C.close(p_stdout[0])
    C.close(p_stderr[0])
    C.close(p_errno[0])
    if stdin then
      local r, e = dup2(p_stdin[0], STDIN)
      if r == -1 then
        local err = int(1, ffi.errno())
        write(p_errno[1], err, ffi.sizeof(err))
        C._exit(0)
      end
    end
    if stdout then
      local r, es = redirect(stdout, STDOUT)
      if r == nil then
        local err = int(1, ffi.errno())
        write(p_errno[1], err, ffi.sizeof(err))
        C._exit(0)
      end
    else
      local r, e = dup2(p_stdout[1], STDOUT)
      if r == -1 then
        local err = int(1, ffi.errno())
        write(p_errno[1], err, ffi.sizeof(err))
        C._exit(0)
      end
    end
    if stderr then
      local r, es = redirect(stderr, STDERR)
      if r == nil then
        local err = int(1, ffi.errno())
        write(p_errno[1], err, ffi.sizeof(err))
        C._exit(0)
      end
    else
      local r, e = dup2(p_stderr[1], STDERR)
      if r == -1 then
        local err = int(1, ffi.errno())
        write(p_errno[1], err, ffi.sizeof(err))
        C._exit(0)
      end
    end
    C.close(p_stdin[0])
    C.close(p_stdout[1])
    C.close(p_stderr[1])
    local string_array_t = ffi.typeof('const char *[?]')
    -- local char_p_k_p_t   = ffi.typeof('char *const*')
    -- args is 1-based Lua table, argv is 0-based C array
    -- automatically NULL terminated
    local argv = string_array_t(#args + 1 + 1)
    for i = 1, #args do
      argv[i] = tostring(args[i])
    end
    do
      local function setenv(name, value)
        local overwrite_flag = 1
        if C.setenv(name, value, overwrite_flag) == -1 then
          local err = int(1, ffi.errno())
          write(p_errno[1], err, ffi.sizeof(err))
          C._exit(0)
        end
      end
      for name, value in pairs(env or {}) do
        setenv(name, tostring(value))
      end
    end
    if cwd then
      if C.chdir(tostring(cwd)) == -1 then
        local err = int(1, ffi.errno())
        write(p_errno[1], err, ffi.sizeof(err))
        C._exit(0)
      end
    end
    C.close(p_errno[1])
    argv[0] = exe
    argv[#args + 1] = nil
    execvp(exe, ffi.cast("char *const*", argv))
    assert(nil, "assertion failed: exec.spawn (should be unreachable!)")
  else

    if stdin then
      local len = string.len(stdin)
      local str = ffi.new("char[?]", len + 1)
      ffi.copy(str, stdin, len)
      local r, e = write(p_stdin[1], str, len)
      if r == -1 then
        R.error = strerror(e, "write(2) failed")
        return nil, R
      end
      C.close(p_stdin[1])
    else
      C.close(p_stdin[1])
    end

    C.close(p_errno[1])
    local err = int(1)
    local n = read(p_errno[0], err, ffi.sizeof(err))
    C.close(p_errno[0])
    if n > 0 then
      R.error = strerror(errno(), "exec failed")
      return nil, R
    end

    do
      local status = ffi.new("int[?]", 1)
      local r, e = C.waitpid(pid, status, 0)
      if r == -1 then
        R.error = strerror(e, "waitpid(2) failed")
        return nil, R
      end
      ret = bit.rshift(bit.band(status[0], 0xff00), 8)
      if ret > 0 then R.error = strerror(errno(), "execvp(2) failed") end
      R.code = ret
    end
    local output = function(i, o)
      local F_GETFL = 0x03
      local F_SETFL = 0x04
      local FD_CLOEXEC = 0x01
      local O_NONBLOCK = 0x800
      local buf = ffi.new("char[?]", 1)
      local flags = C.fcntl(i, F_GETFL, 0)
      flags = bit.bor(flags, O_NONBLOCK)
      flags = bit.bor(flags, FD_CLOEXEC)
      if fcntl(i, F_SETFL, ffi.new("int", flags)) == -1 then
        return nil, strerror(errno(), "fcntl(2) failed")
      end
      local n, s, c
      -- Do not wrap C.read
      while true do
        n = C.read(i, buf, 1)
        if n == 0 then
          break
        elseif n > 0 then
          c = ffi.string(buf, 1)
          if c ~= "\n" then
            s = string.format("%s%s", s or "", c)
          elseif ffi.errno() == C.EAGAIN then
            o[#o+1] = s
            break
          else
            o[#o+1] = s
            s = nil
          end
        elseif ffi.errno() == C.EAGAIN then
          o[#o+1] = s
          break
        else
          return nil, strerror(errno(), "read(2) failed")
        end
      end
      return true
    end
    local sr, se
    sr, se = output(p_stdout[0], R.stdout)
    if sr == nil then
      R.error = se
      return nil, R
    end
    sr, se = output(p_stderr[0], R.stderr)
    if sr == nil then
      R.error = se
      return nil, R
    end
    C.close(p_stdin[0])
    C.close(p_stdin[1])
    C.close(p_stdout[0])
    C.close(p_stdout[1])
    C.close(p_stderr[0])
    C.close(p_stderr[1])
    C.close(p_errno[0])
    C.close(p_errno[1])
  end
  if ret == 0 or ignore then
    return pid, R
  elseif errexit then
    return panic("<errexit> %s %s\n  -- ERROR --\n%s\n  -- STDERR --\n%s\n  -- STDOUT --\n%s\n", exe, table.concat(args, " "),
        R.error or "",
        table.concat(R.p_stderr, "\n"),
        table.concat(R.p_stdout, "\n"))
  else
    return nil, R
  end
end
exec.context = function(exe)
  local set = {}
  return setmetatable(set, {__call = function(_, ...)
    local args = {}
    local n = select("#", ...)
    if n == 1 then
      for k in string.gmatch(..., "%S+") do
        args[#args+1] = k
      end
    elseif n > 1 then
      for _, k in ipairs({...}) do
        args[#args+1] = k
      end
    end
    return exec.spawn(exe, args, set.env, set.cwd, set.stdin, set.stdout, set.stderr, set.ignore, set.errexit)
  end})
end
exec.ctx = exec.context
exec.cmd = setmetatable({},
  {__index =
    function (_, exe)
      return function(...)
        local args
        if not (...) then
          args = {}
        elseif type(...) == "table" then
          args = ...
        else
          args = {...}
        end
        return exec.spawn(exe, args, args.env, args.cwd, args.stdin, args.stdout, args.stderr, args.ignore, args.errexit)
      end
    end
  })
return exec
