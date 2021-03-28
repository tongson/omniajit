#!../bin/moon
T = require "u-test"
arg.path = {}
arg.path.ffi = "."
R = require 'redis'
B = require 'base64'
std = require 'std'
T["redis.set"] = ->
    t = {
        expire: 60,
        key: 'first',
        value: 'one',
    }
    r, e = R.set(t)
    T.is_true(r)
T["redis.hset"] = ->
    t = {
        key: 'hash',
        field: 'nine',
        value: 'nueve',
    }
    r, e = R.hset(t)
    T.is_true(r)
T["redis.hget"] = ->
    t = {
        key: 'hash',
        field: 'nine',
    }
    r, e = R.hget(t)
    T.equal(r, 'nueve')
T["redis.hdel"] = ->
    t = {
        key: 'hash',
        field: 'nine',
    }
    r, e = R.hdel(t)
    T.is_true(r)
    r, e = R.hget(t)
    T.equal(r, '')
T["redis.hset (binary)"] = ->
    ls = std.file.read('/bin/ls')
    t1 = {
        key: 'bin,'
        field: 'contents',
        value: B.encode(ls),
    }
    r, e = R.hset(t1)
    T.is_true(r)
    t2 = {
        key: 'bin',
        field: 'contents'
    }
    r, e = R.hget(t2)
    T.equal(ls, B.decode(r))
T["redis.hsetnx"] = ->
    t = {
        key: 'test'
        field: 'dup'
        value: 'dup'
    }
    r, e = R.hset(t)
    T.is_true(r)
    r, e = R.hsetnx(t)
    T.is_false(r)
    t2 = {
        key: 'test'
        field: 'new'
        value: 'new'
    }
    r, e = R.hsetnx(t2)
    T.is_true(r)
    R.hdel({
        key: 'test',
        field: 'new',
    })
T["redis.set (no expire)"] = ->
    t = {
        key: 'third'
        value: 'three'
    }
    r, e = R.set(t)
    T.is_true(r)
T["redis.get"] = ->
    r3 = R.get 'third'
    T.equal(r3, "three")
T["redis.incr"] = ->
    r = R.incr 'test_incr'
    ret = false
    if r > 0
        ret = true
    T.is_true(ret)
    g = R.get 'test_incr'
    n = tonumber(g)
    T.equal(n, r)
T["redis.del"] = ->
    r = R.del 'third'
    T.is_true(r)
    r = R.get 'third'
    T.equal(r, '')
