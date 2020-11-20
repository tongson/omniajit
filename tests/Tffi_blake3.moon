#!/usr/bin/env moon
T = require "u-test"
blake3 = require "ffi_blake3"
T["ffi_blake3.hash"] = ->
    T.equal("4878ca0425c739fa427f7eda20fe845f6b2e46ba5fe2a14df5b1e32f50603215",
         blake3.hash("test"))
T["ffi_blake3.base64"] = ->
    T.equal("SHjKBCXHOfpCf37aIP6EX2suRrpf4qFN9bHjL1BgMhU=",
         blake3.base64("test"))


