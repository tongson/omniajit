#!../bin/moon
la = require 'lautil'
same = la.deepcompare
T = require 'u-test'
yaml = require 'yaml'
T["string 1"] = ->
  T.is_true(same({
      value: "hello"
    },
    yaml.parse([[
      value: hello #world
    ]])
  ))
T["string 2"] = ->
  T.is_true(same({
      value: "hello# world"
    },
    yaml.parse([[
      value: hello# world
    ]])
  ))
T["string 3"] = ->
  T.is_true(same({
      value: "hello"
    },
    yaml.parse([[
      value: 'hello' # world
    ]])
  ))
