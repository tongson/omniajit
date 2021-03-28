#!../bin/moon
T = require "u-test"
arg.path = {}
arg.path.ffi = "."
R = require 'redis'
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
T["redis.hset"] = ->
    t = {
        hash: {
            nine: "nueve",
            ten: "diyes",
        },
    }
    r, e = R.hset(t)
    T.is_true(r)
T["redis.hget"] = ->
    t = {
        hash: 'hash',
        field: 'ten',
    }
    r, e = R.hget(t)
    T.equal(r, 'diyes')
T["redis.hdel"] = ->
    t = {
        hash: 'hash',
        field: 'nine',
    }
    r, e = R.hdel(t)
    T.is_true(r)
    r, e = R.hget(t)
    T.is_nil(r)
    t = {
        hash: 'hash',
        field: 'ten',
    }
    r, e = R.hget(t)
    T.equal(r, 'diyes')
T["redis.hsetnx"] = ->
    t = {
        test: {
            dup: 'dup',
            delete: 'delete',
        }
    }
    r, e = R.hset(t)
    T.is_true(r)
    t1 = {
        test: {
            dup: 'dup',
        }
    }
    r, e = R.hsetnx(t1)
    T.is_false(r)
    t2 = {
        test: {
            new: 'new',
        }
    }
    r, e = R.hsetnx(t2)
    T.is_true(r)
    R.hdel({
        hash: 'test',
        field: 'new',
    })
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
T["redis.incr"] = ->
    r = R.incr 'test_incr'
    T.is_true(r)
    g = R.get 'test_incr'
    n = tonumber(g)
    T.is_true(n > 0)
T["redis.del"] = ->
    R.del 'third'
    r = R.get 'third'
    T.is_nil(r)
