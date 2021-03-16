#!../bin/moon
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
