local la = require("lautil")
local same = la.deepcompare
local T = require("u-test")
local yaml = require("yaml")
T["string 1"] = function()
	T.is_true(same({
		value = "hello",
	}, yaml.parse([[
      value: hello #world
    ]])))
end
T["string 2"] = function()
	T.is_true(same({
		value = "hello# world",
	}, yaml.parse([[
      value: hello# world
    ]])))
end
T["string 3"] = function()
	T.is_true(same({
		value = "hello",
	}, yaml.parse([[
      value: 'hello' # world
    ]])))
end
