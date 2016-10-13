local T = require("cwtest").new()
do
  T:start("Lua sequence")
  local tbl = {
    "1",
    "2",
    "3",
    "4",
    "5"
  }
  local result = { }
  for _, n in ipairs(tbl) do
    result[#result + 1] = n
  end
  T:eq(table.concat(result), "12345")
  if not T:done() then
    T:exit()
  end
end
do
  T:start("ipairs nil")
  local tbl = {
    "1",
    "2",
    "3",
    "4",
    "5"
  }
  local result = { }
  tbl[4] = nil
  for _, n in ipairs(tbl) do
    result[#result + 1] = n
  end
  T:eq(table.concat(result), "123")
  if not T:done() then
    T:exit()
  end
end
do
  T:start("for loop nil")
  local tbl = {
    "1",
    "2",
    "3",
    "4",
    "5"
  }
  local result = { }
  tbl[4] = nil
  for n = 1, #tbl do
    result[#result + 1] = tbl[n]
  end
  T:eq(table.concat(result), "123")
  if not T:done() then
    T:exit()
  end
end
do
  T:start("next sequence")
  local tbl = {
    "1",
    "2",
    "3",
    "4",
    "5"
  }
  tbl[4] = nil
  local result = { }
  local n = 0
  while next(tbl) do
    n = n + 1
    result[#result + 1] = tbl[n]
    tbl[n] = nil
  end
  T:eq(table.concat(result), "1235")
  if not T:done() then
    T:exit()
  end
end
do
  T:start("Multiple return")
  table.pack = function(...)
    return {
      n = select('#', ...),
      ...
    }
  end
  local test
  test = function()
    return 1, 2, 3
  end
  local a, b, c, d, e = test(), 4, 5
  local result = table.pack(a, b, c, d, e)
  T:eq(table.concat(result), "145")
  if not T:done() then
    T:exit()
  end
end
do
  T:start("Update table 1")
  local tbl = {
    1
  }
  local result = { }
  for k, v in ipairs(tbl) do
    tbl[k + 1] = k + 1
    result[#result + 1] = tbl[k]
    if k == 5 then
      break
    end
  end
  T:eq(table.concat(result), "12345")
  if not T:done() then
    T:exit()
  end
end
do
  T:start("Update table 2")
  local tbl = {
    1
  }
  local result = { }
  for k, v in pairs(tbl) do
    tbl[k + 1] = k + 1
    result[#result + 1] = tbl[k]
    if k == 5 then
      break
    end
  end
  T:eq(table.concat(result), "12345")
  if not T:done() then
    T:exit()
  end
end
do
  T:start("Mixed table 1")
  local tbl = {
    e = true,
    1,
    2
  }
  table.insert(tbl, 1, 0)
  T:eq(table.concat(tbl), "012")
  if not T:done() then
    T:exit()
  end
end
do
  T:start("Mixed table 2")
  local tbl = {
    e = true,
    1,
    2
  }
  table.insert(tbl, 3, 3)
  T:eq(table.concat(tbl), "123")
  if not T:done() then
    T:exit()
  end
end
do
  T:start("Function from a src/lua module(src)")
  local src = require("src")
  T:eq(type(src.src), "function")
  if not T:done() then
    T:exit()
  end
end
do
  T:start("Function from a src/lua module directory (moonscript) (moon.src)")
  local moon_slash_src = require("moon.src")
  T:eq(type(moon_slash_src.moon_slash_src), "function")
  if not T:done() then
    T:exit()
  end
end
do
  T:start("Function from a src/lua module (moonscript) (moon_src)")
  local moon_src = require("moon_src")
  T:eq(type(moon_src.moon_src), "function")
  if not T:done() then
    T:exit()
  end
end
do
  T:start("FFI")
  local F = require("ffi")
  F.cdef("\n   typedef int32_t pid_t;\n   pid_t getpid(void);\n   char *getcwd(char *buf, size_t size);\n   ")
  T:eq(type(F.C.getpid()), "number")
  local buf = F.new("char[256]")
  local size = F.new("size_t", 256)
  F.C.getcwd(buf, size)
  T:eq(string.match(F.string(buf), "OmniaJIT"), "OmniaJIT")
  if not T:done() then
    T:exit()
  end
end
do
  T:start("ljsyscall(lfs)")
  local L = require("lfs")
  T:eq(string.match(L.currentdir(), "OmniaJIT"), "OmniaJIT")
  if not T:done() then
    T:exit()
  end
  return T
end