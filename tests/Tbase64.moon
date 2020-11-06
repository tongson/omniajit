#!/usr/bin/env moon
b64 = require "base64"
la = require "lautil"
same = la.deepcompare
T = require "u-test"

T["RFC4648 test"] = ->
    T.equal(b64.encode(""), "")
    T.equal(b64.encode("f"), "Zg==")
    T.equal(b64.encode("fo"), "Zm8=")
    T.equal(b64.encode("foo"), "Zm9v")
    T.equal(b64.encode("foob"), "Zm9vYg==")
    T.equal(b64.encode("fooba"), "Zm9vYmE=")
    T.equal(b64.encode("foobar"), "Zm9vYmFy")

