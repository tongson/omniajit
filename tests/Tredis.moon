#!/usr/bin/env moon
T = require "u-test"
arg.path = {}
arg.path.ffi = "."
R = require 'redis'
T["redis.incr"] = ->
    r = R.incr 'test_incr'
    T.is_true(r)
T["redis.set"] = ->
    t = {
        expire: 60,
        data: {
            first: "one",
            second: "two",
        }
    }
    r, e = R.set(t)
    T.is_true(r)
T["redis.set (no expire)"] = ->
    t = {
        data: {
            third: "three",
            fourth: "four",
        }
    }
    r, e = R.set(t)
    T.is_true(r)
T["redis.get"] = ->
    r1 = R.get 'first'
    r3 = R.get 'third'
    T.equal(r1, "one")
    T.equal(r3, "three")
T["redis.del"] = ->
    R.del 'third'
    r = R.get 'third'
    T.is_nil(r)
T["redis.json_set"] = ->
    t = { name: 'ed', location: 'earth', age: 40, father: true }
    x = { key: 'REJSON_test', path: '.', data: t }
    r = R.json_set(x)
    T.is_true(r)
T["redis.json_get"] = ->
    n = { key: 'REJSON_test', path: '.name' }
    l = { key: 'REJSON_test', path: '.location' }
    a = { key: 'REJSON_test', path: '.age' }
    f = { key: 'REJSON_test', path: '.father' }
    n = R.json_get(n)
    l = R.json_get(l)
    a = R.json_get(a)
    f = R.json_get(f)
    T.equal(n, 'ed')
    T.equal(l, 'earth')
    T.equal(a, 40)
    T.is_true(f)
