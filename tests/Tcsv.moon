#!/usr/bin/env moon
csv = require "csv"
la = require "lautil"
same = la.deepcompare
T = require "u-test"


T["should handle loading from string"] = ->
    actual = csv.parse("a,b,c\napple,banana,carrot", ",", {loadFromString: true})
    expected = {}
    expected[1] = {}
    expected[1].a = "apple"
    expected[1].b = "banana"
    expected[1].c = "carrot"
    T.is_true(same(expected, actual))

T["should handle quotes"] = ->
    actual = csv.parse('"a","b","c"\n"apple","banana","carrot"', ",", {loadFromString: true})
    expected = {}
    expected[1] = {}
    expected[1].a = "apple"
    expected[1].b = "banana"
    expected[1].c = "carrot"
    T.is_true(same(expected, actual))

T["should handle double quotes"] = ->
    actual = csv.parse('"a","b","c"\n"""apple""","""banana""","""carrot"""', ",", {loadFromString: true})
    expected = {}
    expected[1] = {}
    expected[1].a = '"apple"'
    expected[1].b = '"banana"'
    expected[1].c = '"carrot"'
    T.is_true(same(expected, actual))
