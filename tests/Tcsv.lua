local included = pcall(debug.getlocal, 6, 1)
local csv = require("csv")
local la = require("lautil")
local same = la.deepcompare
local T = require("u-test")
local load_string = function()
	local actual = csv.parse("a,b,c\napple,banana,carrot", ",", {
		loadFromString = true,
	})
	local expected = {}
	expected[1] = {}
	expected[1].a = "apple"
	expected[1].b = "banana"
	expected[1].c = "carrot"
	return T.is_true(same(expected, actual))
end
local quotes = function()
	local actual = csv.parse('"a","b","c"\n"apple","banana","carrot"', ",", {
		loadFromString = true,
	})
	local expected = {}
	expected[1] = {}
	expected[1].a = "apple"
	expected[1].b = "banana"
	expected[1].c = "carrot"
	return T.is_true(same(expected, actual))
end
local double = function()
	local actual = csv.parse('"a","b","c"\n"""apple""","""banana""","""carrot"""', ",", {
		loadFromString = true,
	})
	local expected = {}
	expected[1] = {}
	expected[1].a = '"apple"'
	expected[1].b = '"banana"'
	expected[1].c = '"carrot"'
	return T.is_true(same(expected, actual))
end
if included then
	return function()
		T["should handle loading from string"] = load_string
		T["should handle quotes"] = quotes
		T["should handle double quotes"] = double
	end
else
	T["should handle loading from string"] = load_string
	T["should handle quotes"] = quotes
	T["should handle double quotes"] = double
end
