#!/usr/bin/env moon
uuid = require("uuid")
T = require("u-test")

-- start tests

T["generating a uuid"] = ->
    T.is_string(uuid.new!)
    T.is_string(uuid!)

T["format of the generated uuid"] = ->
    for i = 1, 1000    -- some where to short, see issue #1, so test a bunch
      u = uuid!
      T.equal("-", u\sub(9,9))
      T.equal("-", u\sub(14,14))
      T.equal("-", u\sub(19,19))
      T.equal("-", u\sub(24,24))
      T.equal(36, #u)

T["hwaddr parameter"] = ->
    T.error_raised(uuid("12345678901"))        -- too short
    T.error_raised(uuid("123a4::xxyy;;590"))   -- too short after clean
    T.error_raised(uuid(true))                 -- not a string
    T.error_raised(uuid(123))                  -- not a string
    T.is_string(uuid("abcdefabcdef"))   -- hex only
    T.is_string(uuid("123456789012"))   -- right size
    T.is_string(uuid("1234567890123"))  -- oversize


T["uuid.randomseed() properly limits the value"] = ->
    bitsize = 32
    T.equal(12345, uuid.randomseed(12345))
    T.equal(12345, uuid.randomseed(12345 + 2^bitsize))
