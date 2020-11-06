#!/usr/bin/env moon
T = require "u-test"
lpeg = require "lpeg"
lh = require"lhutil"
uri_lib = require "lpeg_patterns.uri"
uri = uri_lib.uri * lpeg.P(-1)
la = require "lautil"
same = la.deepcompare
T.lpeg_patterns = ->
    t = { scheme: "scheme"
          host: "host"
          port: 1234
          path: "/path"
        }
    u = uri\match "scheme://host:1234/path"
    T.equal(t.scheme, u.scheme)
    T.equal(t.host, u.host)
    T.equal(t.port, u.port)
    T.equal(t.path, u.path)
T["decodeURI works"] = ->
    T.equal("Encoded string", lh.decodeURI("Encoded%20string"))
T["decodeURI doesn't decode blacklisted characters"] = ->
    T.equal("%24", lh.decodeURI("%24"))
    s = lh.encodeURIComponent("#$&+,/:;=?@")
    T.equal(s, lh.decodeURI(s))
T["decodeURIComponent round-trips with encodeURIComponent"] = ->
    t = {}
    allchars = 0
    for i = 0,255 do t[i] = i
    allchars = string.char(table.unpack(t, 0, 255))
    T.equal(allchars, lh.decodeURIComponent(lh.encodeURIComponent(allchars)))
T["query_args works"] = ->
    do
        iter, state, first = lh.query_args("foo=bar")
        T.is_true(same({"foo", "bar"}, {iter(state, first)}))
        T.equal(nil, iter(state, first))
    do
        iter, state, first = lh.query_args("foo=bar&baz=qux&foo=somethingelse")
        T.is_true(same({"foo", "bar"}, {iter(state, first)}))
        T.is_true(same({"baz", "qux"}, {iter(state, first)}))
        T.is_true(same({"foo", "somethingelse"}, {iter(state, first)}))
        T.is_true(same(nil, iter(state, first)))
    do
        iter, state, first = lh.query_args("%3D=%26")
        T.is_true(same({"=", "&"}, {iter(state, first)}))
        T.is_true(same(nil, iter(state, first)))
    do
        iter, state, first = lh.query_args("foo=bar&noequals")
        T.is_true(same({"foo", "bar"}, {iter(state, first)}))
        T.is_true(same({"noequals", nil}, {iter(state, first)}))
        T.is_true(same(nil, iter(state, first)))
T["dict_to_query works"] = ->
    T.equal("foo=bar", lh.dict_to_query{foo: "bar"})
    T.equal("foo=%CE%BB", lh.dict_to_query{foo: "λ"})
    do
        t = {foo: "bar", baz: "qux"}
        r = {}
        for k, v in lh.query_args(lh.dict_to_query(t))
            r[k] = v
        T.is_true(same(t, r))
T["is_safe_method works"] = ->
    T.is_true(lh.is_safe_method "GET")
    T.is_true(lh.is_safe_method "HEAD")
    T.is_true(lh.is_safe_method "OPTIONS")
    T.is_true(lh.is_safe_method "TRACE")
    T.is_false(lh.is_safe_method "POST")
    T.is_false(lh.is_safe_method "PUT")
T["is_ip works"] = ->
    T.is_true(lh.is_ip "127.0.0.1")
    T.is_true(lh.is_ip "192.168.1.1")
    T.is_true(lh.is_ip "::")
    T.is_true(lh.is_ip "::1")
    T.is_true(lh.is_ip "2001:0db8:85a3:0042:1000:8a2e:0370:7334")
    T.is_true(lh.is_ip "::FFFF:204.152.189.116")
    T.is_false(lh.is_ip "not an ip")
    T.is_false(lh.is_ip "0x80")
    T.is_false(lh.is_ip "::FFFF:0.0.0")
T["split_authority works"] = ->
    T.is_true(same({"example.com", 80}, {lh.split_authority("example.com", "http")}))
    T.is_true(same({"example.com", 8000}, {lh.split_authority("example.com:8000", "http")}))
    T.is_nil(lh.split_authority("example.com", "madeupscheme"))
    T.is_true(same({"::1", 443}, {lh.split_authority("[::1]", "https")}))
    T.is_true(same({"::1", 8000}, {lh.split_authority("[::1]:8000", "https")}))
T["to_authority works"] = ->
    T.is_true(same("example.com", lh.to_authority("example.com", 80, "http")))
    T.is_true(same("example.com:8000", lh.to_authority("example.com", 8000, "http")))
    T.is_true(same("[::1]", lh.to_authority("::1", 443, "https")))
    T.is_true(same("[::1]:8000", lh.to_authority("::1", 8000, "https")))
T["generates correct looking Data header format"] = ->
    T.equal("Fri, 13 Feb 2009 23:31:30 GMT", lh.imf_date(1234567890))
T["maybe_quote: makes acceptable tokens or quoted-string"] = ->
    T.is_true(same([[foo]], lh.maybe_quote([[foo]])))
    T.is_true(same([["with \" quote"]], lh.maybe_quote([[with " quote]])))
T["maybe_quote: escapes all bytes correctly"] = ->
    http_patts = require "lpeg_patterns.http"
    local s
    do -- Make a string containing every byte allowed in a quoted string
        t = {"\t"} -- tab
        for i=32, 126
            t[#t+1] = string.char(i)
        for i=128, 255
            t[#t+1] = string.char(i)
        s = table.concat(t)
    T.is_true(same(s, http_patts.quoted_string\match(lh.maybe_quote(s))))
T["maybe_quote: returns nil on invalid input"] = ->
    check = (s) ->
        T.is_nil(lh.maybe_quote(s))
    for i=0, 8
        check(string.char(i))
    -- skip tab
    for i=10, 31
        check(string.char(i))
    check("\127")
T["yieldable_pcall: returns multiple return values"] = ->
    f = ->
        return 1, 2, 3, 4, nil, nil, nil, nil, nil, nil, "foo"
    T.is_true(same({true, 1, 2, 3, 4, nil, nil, nil, nil, nil, nil, "foo"},
        {lh.yieldable_pcall(f)}))
T["yieldable_pcall: protects from errors"] = ->
    T.is_false(lh.yieldable_pcall(error))
T["yieldable_pcall: return error objects"] = ->
    err = {"myerror"}
    ok, err2 = lh.yieldable_pcall(error, err)
    T.is_false(ok)
    T.equal(err, err2)
T["yieldable_pcall: works on all levels"] = ->
    fn = -> return lh.yieldable_pcall(coroutine.yield, true)
    f = coroutine.wrap(fn)
    T.is_true(f!)
    T.is_true(f!)
    T.error_raised(f)
T["yieldable_pcall: works with __call objects"] = ->
    done = false
    f = -> done = true
    o = setmetatable({}, { __call: f })
    lh.yieldable_pcall(o)
    T.is_true(done)
