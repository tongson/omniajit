T = require"cwtest".new!

with T
   \start "Lua sequence"
   tbl={"1", "2", "3", "4", "5"}
   result = {}
   for _,n in ipairs(tbl)
      result[#result+1]=n
   \eq table.concat(result), "12345"
   \exit! if not \done!
with T
   \start "ipairs nil"
   tbl={"1", "2", "3", "4", "5"}
   result={}
   tbl[4]=nil
   for _,n in ipairs(tbl)
      result[#result+1]=n
   \eq table.concat(result), "123"
   \exit! if not \done!
with T
   \start "for loop nil"
   tbl={"1", "2", "3", "4", "5"}
   result={}
   tbl[4]=nil
   for n=1,#tbl
      result[#result+1]=tbl[n]
   \eq table.concat(result), "123" -- 1235 on PUC-Rio Lua 5.3
   \exit! if not \done!
with T
   \start "next sequence"
   tbl={"1", "2", "3", "4", "5"}
   tbl[4]=nil
   result={}
   n = 0
   while next(tbl)
      n = n + 1
      result[#result+1]=tbl[n]
      tbl[n]=nil
   \eq table.concat(result), "1235"
   \exit! if not \done!
with T
   \start "Multiple return"
   table.pack = (...) ->
      {
         n: select('#',...)
         ...
      }
   test = ->
      1, 2, 3
   a, b, c, d, e = test!, 4, 5
   result = table.pack(a, b, c, d, e)
   \eq table.concat(result), "145"
   \exit! if not \done!
with T
   \start "Update table 1"
   tbl={1}
   result={}
   for k,v in ipairs(tbl)
      tbl[k+1]=k+1
      result[#result+1]=tbl[k]
      if k==5 then break
   \eq table.concat(result), "12345"
   \exit! if not \done!
with T
   \start "Update table 2"
   tbl={1}
   result={}
   for k,v in pairs(tbl)
      tbl[k+1]=k+1
      result[#result+1]=tbl[k]
      if k==5 then break
   \eq table.concat(result), "12345"
   \exit! if not \done!
with T
   \start "Mixed table 1"
   tbl={e: true,1,2}
   table.insert(tbl, 1, 0)
   \eq table.concat(tbl), "012"
   \exit! if not \done!
with T
   \start "Mixed table 2"
   tbl={e: true,1,2}
   table.insert(tbl, 3, 3)
   \eq table.concat(tbl), "123"
   \exit! if not \done!
with T
   \start "Function from a src/lua module(src)"
   src = require"src"
   \eq type(src.src), "function"
   \exit! if not \done!
with T
   \start "Function from a src/lua module directory (moonscript) (moon.src)"
   moon_slash_src = require"moon.src"
   \eq type(moon_slash_src.moon_slash_src), "function"
   \exit! if not \done!
with T
   \start "Function from a src/lua module (moonscript) (moon_src)"
   moon_src = require"moon_src"
   \eq type(moon_src.moon_src), "function"
   \exit! if not \done!
with T
   \start "FFI"
   F = require"ffi"
   F.cdef"
   typedef int32_t pid_t;
   pid_t getpid(void);
   char *getcwd(char *buf, size_t size);
   "
   \eq type(F.C.getpid()), "number"
   buf = F.new("char[256]")
   size = F.new("size_t", 256)
   F.C.getcwd(buf, size)
   \eq string.match(F.string(buf), "OmniaJIT"), "OmniaJIT"
   \exit! if not \done!
with T
   \start "ljsyscall(lfs)"
   L = require"lfs"
   \eq string.match(L.currentdir!, "OmniaJIT"), "OmniaJIT"
   \exit! if not \done!
