local included = pcall(debug.getlocal, 6, 1)
local la = require("lautil")
local same = la.deepcompare
local T = require("u-test")
local yaml = require("yaml")
local string_1 = function()
	T.is_true(same({
		value = "hello",
	}, yaml.parse([[
      value: hello #world
    ]])))
end
local string_2 = function()
	T.is_true(same({
		value = "hello# world",
	}, yaml.parse([[
      value: hello# world
    ]])))
end
local string_3 = function()
	T.is_true(same({
		value = "hello",
	}, yaml.parse([[
      value: 'hello' # world
    ]])))
end
if included then
	return function()
		T["string 1"] = string_1
		T["string 2"] = string_2
		T["string 3"] = string_3
	end
else
	T["string 1"] = string_1
	T["string 2"] = string_2
	T["string 3"] = string_3
end
