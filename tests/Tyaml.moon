#!../bin/moon
la = require 'lautil'
same = la.deepcompare
T = require 'u-test'
yaml = require 'yaml'
T["string 1"] = ->
  same({
      value: "hello"
    },
    yaml.parse([[
      value: hello #world
    ]])
  )
T["string 2"] = ->
  same({
      value: "hello# world"
    },
    yaml.parse([[
      value: hello# world
    ]])
  )
T["string 3"] = ->
  same({
      value: "hello"
    },
    yaml.parse([[
      value: 'hello' # world
    ]])
  )

