T = require"tapered"

with T
   M = "Lua sequence"
   tbl={"1", "2", "3", "4", "5"}
   result = {}
   for _,n in ipairs(tbl)
      result[#result+1]=n
   .same table.concat(result), "12345", M
with T
   M = "ipairs nil"
   tbl={"1", "2", "3", "4", "5"}
   result={}
   tbl[4]=nil
   for _,n in ipairs(tbl)
      result[#result+1]=n
   .same table.concat(result), "123", M
with T
   M = "for loop nil"
   tbl={"1", "2", "3", "4", "5"}
   result={}
   tbl[4]=nil
   for n=1,#tbl
      result[#result+1]=tbl[n]
   .same table.concat(result), "123", M -- 1235 on PUC-Rio Lua 5.3
with T
   M = "next sequence"
   tbl={"1", "2", "3", "4", "5"}
   tbl[4]=nil
   result={}
   n = 0
   while next(tbl)
      n = n + 1
      result[#result+1]=tbl[n]
      tbl[n]=nil
   .same table.concat(result), "1235", M
with T
   M = "Multiple return"
   table.pack = (...) ->
      {
         n: select('#',...)
         ...
      }
   test = ->
      1, 2, 3
   a, b, c, d, e = test!, 4, 5
   result = table.pack(a, b, c, d, e)
   .same table.concat(result), "145", M
with T
   M = "Update table 1"
   tbl={1}
   result={}
   for k,v in ipairs(tbl)
      tbl[k+1]=k+1
      result[#result+1]=tbl[k]
      if k==5 then break
   .same table.concat(result), "12345", M
with T
   M = "Update table 2"
   tbl={1}
   result={}
   for k,v in pairs(tbl)
      tbl[k+1]=k+1
      result[#result+1]=tbl[k]
      if k==5 then break
   .same table.concat(result), "12345", M
with T
   M = "Mixed table 1"
   tbl={e: true,1,2}
   table.insert(tbl, 1, 0)
   .same table.concat(tbl), "012", M
with T
   M = "Mixed table 2"
   tbl={e: true,1,2}
   table.insert(tbl, 3, 3)
   .same table.concat(tbl), "123", M
with T
   M = "Function from a src/lua module(src)"
   src = require"src"
   .same type(src.src), "function", M
with T
   M = "Function from a src/lua module directory (moonscript) (moon.src)"
   moon_slash_src = require"moon.src"
   .same type(moon_slash_src.moon_slash_src), "function", M
with T
   M ="Function from a src/lua module (moonscript) (moon_src)"
   moon_src = require"moon_src"
   .same type(moon_src.moon_src), "function", M
with T
   F = require"ffi"
   F.cdef"
   typedef int32_t pid_t;
   pid_t getpid(void);
   char *getcwd(char *buf, size_t size);
   "
   .same type(F.C.getpid()), "number", "FFI 1"
   buf = F.new("char[256]")
   size = F.new("size_t", 256)
   F.C.getcwd(buf, size)
   .same string.match(F.string(buf), "OmniaJIT"), "OmniaJIT", "FFI 2"
with T
   M = "ljsyscall(lfs)"
   L = require"lfs"
   .same string.match(L.currentdir!, "OmniaJIT"), "OmniaJIT", M

T.done(15)
