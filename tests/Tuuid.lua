local included = pcall(debug.getlocal, 6, 1)
local uuid = require("uuid")
local T = require("u-test")

local generating_a_uuid = function()
	T.is_string(uuid.new())
	T.is_string(uuid())
end

local format_of_the_generated_uuid = function()
	for i = 1, 1000 do -- some where to short, see issue #1, so test a bunch
		local u = uuid()
		T.equal("-", u:sub(9, 9))
		T.equal("-", u:sub(14, 14))
		T.equal("-", u:sub(19, 19))
		T.equal("-", u:sub(24, 24))
		T.equal(36, #u)
	end
end

local hwaddr_parameter = function()
	T.error_raised(uuid("12345678901")) -- too short
	T.error_raised(uuid("123a4::xxyy;;590")) -- too short after clean
	T.error_raised(uuid(true)) -- not a string
	T.error_raised(uuid(123)) -- not a string
	T.is_string(uuid("abcdefabcdef")) -- hex only
	T.is_string(uuid("123456789012")) -- right size
	T.is_string(uuid("1234567890123")) -- oversize
end

local randomseed_properly_limits_the_value = function()
	bitsize = 32
	T.equal(12345, uuid.randomseed(12345))
	T.equal(12345, uuid.randomseed(12345 + 2 ^ bitsize))
end
if included then
	return function()
		T["generating a uuid"] = generating_a_uuid
		T["format of the generated uuid"] = format_of_the_generated_uuid
		T["hwaddr parameter"] = hwaddr_parameter
		T["uuid.randomseed() properly limits the value"] =
			randomseed_properly_limits_the_value
	end
else
	T["generating a uuid"] = generating_a_uuid
	T["format of the generated uuid"] = format_of_the_generated_uuid
	T["hwaddr parameter"] = hwaddr_parameter
	T["uuid.randomseed() properly limits the value"] =
		randomseed_properly_limits_the_value
end
