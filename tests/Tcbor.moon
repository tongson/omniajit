#!../bin/moon
c1 = require 'cbor'
package.loaded['cbor'] = nil
c2 = require 'cbor'
T = require 'u-test'
compare = (require 'lautil').deepcompare
T["Should be different tables"] = ->
  T.is_false(compare(c1, c2))

t1 = { 10, 20, 30, 40, 50 }
t2 = { 10, 20, nil, 40 }

T["Sequence in array"] = ->
  T.is_true(compare(c1.encode(t1)\byte!, c1.ARRAY(5)\byte!))
  T.is_true(compare(c1.decode(c1.encode(t1)), t1 ))

T["Array with hole in map"] = ->
  T.is_true(compare(c1.encode(t2)\byte!, c1.MAP(3)\byte!))
  T.is_true(compare(c1.decode(c1.encode(t2)), t2))

c1.set_array'with_hole'
c2.set_array'always_as_map'

T["Sequence in array"] = ->
  T.is_true(compare(c1.encode(t1)\byte!, c1.ARRAY(5)\byte!))
  T.is_true(compare(c1.decode(c1.encode(t1)), t1))

T["Array with hole in array"] = ->
  T.is_true(compare(c1.encode(t2)\byte!, c1.ARRAY(4)\byte!))
  T.is_true(compare(c1.decode(c1.encode(t2)), t2))

T["Sequence in map"] = ->
  T.is_true(compare(c2.encode(t1)\byte!, c2.MAP(5)\byte!))
  T.is_true(compare(c1.decode(c1.encode(t1)), t1))

T["Array with hole in map"] = ->
  T.is_true(compare(c2.encode(t2)\byte!, c2.MAP(3)\byte!))
  T.is_true(compare(c2.decode(c2.encode(t2)), t2))
