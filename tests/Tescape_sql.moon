#!../bin/moon
lib = require 'std'
T = require 'u-test'
T["test"] = ->
  --print(lib.string.hexdump(lib.util.escape_sql(string.char(0,98,41,39))))
  T.equal(lib.util.escape_sql(string.char(0,98,41,39)), [['b)''']])
