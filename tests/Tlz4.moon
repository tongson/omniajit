#!../bin/moon
arg.path = {}
arg.path.ffi = '.'
T = require 'u-test'
lz4 = require 'lz4'

T["test"] = ->
  data = "hello lz4"
  compressed_data, errmsg = lz4.compress(data)
  decompressed_data, errmsg = lz4.decompress(compressed_data)
  T.equal(18, compressed_data\len!)
  T.equal(decompressed_data, data)

T["test"] = ->
  data = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa"
  compressed_data, errmsg = lz4.compress(data)
  decompressed_data, errmsg = lz4.decompress(compressed_data)
  T.equal(19, compressed_data\len!)
  T.equal(decompressed_data, data)

