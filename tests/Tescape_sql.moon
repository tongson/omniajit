#!/usr/bin/env moon
lib = require 'std'
print(string.char(97, 98, 99, 0, 100, 101, 102))
print(lib.util.escape_sql(string.char(0,98,41,39)))
