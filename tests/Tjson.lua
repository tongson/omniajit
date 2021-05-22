local included = pcall(debug.getlocal, 6, 1)
local T = require("u-test")
local lj = require("json")
local saxtbl = {}
local bufsize = 64 -- or 1
local fp = io.open("tests/json.dat")
local input
input = function()
	local s = fp:read(bufsize)
	if not s then
		fp:close()
		fp = nil
	end
	return s
end
local parser = lj.newparser(input, saxtbl)
local first_a = function()
	T.equal(parser.tryc(), string.byte("a"))
end
local abc = function()
	T.equal(parser.read(3), "abc")
end
local abcx = function()
	T.equal(
		parser.read(75),
		"abcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabc"
	)
end
local read_78 = function()
	T.equal(parser.tellpos(), 79)
end
local first_json_end_at_139 = function()
	parser.run()
	T.equal(parser.tellpos(), 139)
end
local __mmm = function()
	T.equal(parser.read(8), "  mmmmmm")
end
local ampersand = function()
	parser.run()
	T.equal(parser.tryc(), string.byte("&"))
end
local ampersand_plus_asterisk = function()
	T.equal(
		parser.read(200),
		"&++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	)
end
local last_pos = function()
	T.equal(parser.tellpos(), 276)
	print(parser.tellpos())
end
local ended = function()
	T.is_nil(parser.tryc())
end
local empty = function()
	T.equal(parser.read(10), "")
end
local last_pos_moving = function()
	T.equal(parser.tellpos(), 276)
end
if included then
	return function()
		T["1st a"] = first_a
		T["abc"] = abc
		T["abcx"] = abcx
		T["read 78"] = read_78
		T["1st json end at 139"] = first_json_end_at_139
		T["__mmmmmmm"] = __mmm
		T["&"] = ampersand
		T["&+*"] = ampersand_plus_asterisk
		T["last pos"] = last_pos
		T["ended"] = ended
		T["empty"] = empty
		T["last pos moving"] = last_pos_moving
	end
else
	T["1st a"] = first_a
	T["abc"] = abc
	T["abcx"] = abcx
	T["read 78"] = read_78
	T["1st json end at 139"] = first_json_end_at_139
	T["__mmmmmmm"] = __mmm
	T["&"] = ampersand
	T["&+*"] = ampersand_plus_asterisk
	T["last pos"] = last_pos
	T["ended"] = ended
	T["empty"] = empty
	T["last pos moving"] = last_pos_moving
end
