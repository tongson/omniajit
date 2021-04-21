local included = pcall(debug.getlocal, 6, 1)
local c1 = require("cbor")
package.loaded["cbor"] = nil
local c2 = require("cbor")
local T = require("u-test")
local compare = (require("lautil")).deepcompare
local diff_tables = function()
	return T.is_false(compare(c1, c2))
end
local t1 = {
	10,
	20,
	30,
	40,
	50,
}
local t2 = {
	10,
	20,
	nil,
	40,
}
local seq_array1 = function()
	T.is_true(compare(c1.encode(t1):byte(), c1.ARRAY(5):byte()))
	return T.is_true(compare(c1.decode(c1.encode(t1)), t1))
end
local array_hole_map = function()
	T.is_true(compare(c1.encode(t2):byte(), c1.MAP(3):byte()))
	return T.is_true(compare(c1.decode(c1.encode(t2)), t2))
end
c1.set_array("with_hole")
c2.set_array("always_as_map")
local seq_array2 = function()
	T.is_true(compare(c1.encode(t1):byte(), c1.ARRAY(5):byte()))
	return T.is_true(compare(c1.decode(c1.encode(t1)), t1))
end
local array_hole_array = function()
	T.is_true(compare(c1.encode(t2):byte(), c1.ARRAY(4):byte()))
	return T.is_true(compare(c1.decode(c1.encode(t2)), t2))
end
local seq_map = function()
	T.is_true(compare(c2.encode(t1):byte(), c2.MAP(5):byte()))
	return T.is_true(compare(c1.decode(c1.encode(t1)), t1))
end
local array_hole_map = function()
	T.is_true(compare(c2.encode(t2):byte(), c2.MAP(3):byte()))
	return T.is_true(compare(c2.decode(c2.encode(t2)), t2))
end
if included then
	return function()
		T["Should be different tables"] = diff_tables
		T["Sequence in array"] = seq_array1
		T["Array with hole in map"] = array_hole_map
		T["Sequence in array"] = seq_array2
		T["Array with hole in array"] = array_hole_array
		T["Sequence in map"] = seq_map
		T["Array with hole in map"] = array_hole_map
	end
else
	T["Should be different tables"] = diff_tables
	T["Sequence in array"] = seq_array1
	T["Array with hole in map"] = array_hole_map
	T["Sequence in array"] = seq_array2
	T["Array with hole in array"] = array_hole_array
	T["Sequence in map"] = seq_map
	T["Array with hole in map"] = array_hole_map
end
