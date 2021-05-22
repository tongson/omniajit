local included = pcall(debug.getlocal, 6, 1)
local T = require("u-test")
local test = function()
	T.is_nil(dofile("tests/lpeg/test.lua"))
end
if included then
	return function()
		T["tests"] = test
	end
else
	T["tests"] = test
end

