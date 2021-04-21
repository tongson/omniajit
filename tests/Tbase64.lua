local included = pcall(debug.getlocal, 6, 1)
local b64 = require("base64")
local fast = require("base64_fast").fast
local T = require("u-test")
local rfc4647_plain = function()
	T.equal(b64.encode(""), "")
	T.equal(b64.encode("f"), "Zg==")
	T.equal(b64.encode("fo"), "Zm8=")
	T.equal(b64.encode("foo"), "Zm9v")
	T.equal(b64.encode("foob"), "Zm9vYg==")
	T.equal(b64.encode("fooba"), "Zm9vYmE=")
	T.equal(b64.encode("foobar"), "Zm9vYmFy")
end
local rfc4648_fast = function()
	T.equal(fast(""), "")
	T.equal(fast("f"), "Zg==")
	T.equal(fast("fo"), "Zm8=")
	T.equal(fast("foo"), "Zm9v")
	T.equal(fast("foob"), "Zm9vYg==")
	T.equal(fast("fooba"), "Zm9vYmE=")
	T.equal(fast("foobar"), "Zm9vYmFy")
end
if included then
	return function()
		T["RFC4647 PLAIN"] = rfc4647_plain
		T["RFC4648 FAST"] = rfc4648_fast
	end
else
	T["RFC4647 PLAIN"] = rfc4647_plain
	T["RFC4648 FAST"] = rfc4648_fast

	local bench
	bench = function(fn)
		local s = ""
		for i = 1, 1000 do
			s = s .. "0123456789"
		end
		local n = 50000
		local o = os.clock()
		local encoded
		for i = 1, n do
			encoded = fn(s)
		end
		local dt = os.clock() - o
		return print("bench-enc len:", #s, "n:", n, dt, "sec")
	end
	bench(fast)
	bench(b64.encode)
end
