#!/usr/bin/env moon
b64 = require"ffi_base64"
fast = require"base64_fast".fast
T = require "u-test"

T["RFC4648 plain"] = ->
    T.equal(b64.encode(""), "")
    T.equal(b64.encode("f"), "Zg==")
    T.equal(b64.encode("fo"), "Zm8=")
    T.equal(b64.encode("foo"), "Zm9v")
    T.equal(b64.encode("foob"), "Zm9vYg==")
    T.equal(b64.encode("fooba"), "Zm9vYmE=")
    T.equal(b64.encode("foobar"), "Zm9vYmFy")

T["RFC4648 fast"] = ->
    T.equal(fast(""), "")
    T.equal(fast("f"), "Zg==")
    T.equal(fast("fo"), "Zm8=")
    T.equal(fast("foo"), "Zm9v")
    T.equal(fast("foob"), "Zm9vYg==")
    T.equal(fast("fooba"), "Zm9vYmE=")
    T.equal(fast("foobar"), "Zm9vYmFy")

bench = (fn) ->

    s =""
    for i=1,1000
        s = s .. "0123456789"
    n = 50000
    o = os.clock()
    local encoded
    for i=1,n do
        encoded = fn(s)
    dt = os.clock() - o
    print("bench-enc len:",#s,"n:",n,dt,"sec")

bench(fast)
bench(b64.encode)
