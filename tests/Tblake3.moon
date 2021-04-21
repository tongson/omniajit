#!../bin/moon
arg.path = {}
arg.path.ffi = '.'
T = require 'u-test'
S = require 'std'
blake3 = require "blake3"
T["ffi_blake3.hash"] = ->
    T.equal('4878ca0425c739fa427f7eda20fe845f6b2e46ba5fe2a14df5b1e32f50603215',
         blake3.hash('test'))
T["ffi_blake3.hash (binary)"] = ->
    p = S.file.read '/bin/ls'
    T.equal('', blake3.hash(p))
