local included = pcall(debug.getlocal, 6, 1)
local lst = require("list").new()
local T = require("u-test")

lst:pushl("b") -- push last 'b'
lst:pushf("a") -- push first 'a'

for i = 1, 4, 1 do
	lst:pushl(tostring(i)) -- push last '1, 2, 3, 4'
end

lst:pushl({ 5, 6, 7 }) -- push table
lst:pushl(8) -- push number
lst:pushl(true) -- push boolean

lst:remove("3") -- remove '3', in middle
lst:popf() -- pop first 'a'

lst:pushl("end") -- push 'end'
lst:popl() -- pop 'end'

local walk = function()
	for k, v in lst:walk() do
		if k == 1 then
			T.equal(v, "b")
		end
		if k == 2 then
			T.equal(v, "1")
		end
		if k == 3 then
			T.equal(v, "2")
		end
		if k == 4 then
			T.equal(v, "4")
		end
		if k == 5 then
			T.is_table(v)
		end
		if k == 6 then
			T.is_number(v)
		end
		if k == 7 then
			T.is_true(v)
		end
	end
end
local range = function()
	for i, v in ipairs(lst:range(2, 3)) do
		if i == 1 then
			T.equal(v, "1")
		end
		if i == 2 then
			T.equal(v, "2")
		end
	end
end

local insert = function()
	lst:insertf("0", "1") -- insert front of '1'
	lst:insertl("3", "2") -- insert after of '2'
	for k, v in lst:walk() do
		if k == 1 then
			T.equal(v, "b")
		end
		if k == 2 then
			T.equal(v, "0")
		end
		if k == 3 then
			T.equal(v, "1")
		end
		if k == 4 then
			T.equal(v, "2")
		end
		if k == 5 then
			T.equal(v, "3")
		end
		if k == 6 then
			T.equal(v, "4")
		end
		if k == 7 then
			T.is_table(v)
		end
		if k == 8 then
			T.is_number(v)
		end
		if k == 9 then
			T.is_true(v)
		end
	end
end

local pop = function()
	T.is_true(lst:popl())
	T.is_number(lst:popl())
	T.is_table(lst:popl())
	T.equal(lst:popl(), "4")
	T.equal(lst:popl(), "3")
	T.equal(lst:popl(), "2")
	T.equal(lst:popl(), "1")
	T.equal(lst:popl(), "0")
	T.equal(lst:popl(), "b")
end

if included then
	return function()
		T["walk"] = walk
		T["range"] = range
		T["insert"] = insert
		T["pop"] = pop
	end
else
	T["walk"] = walk
	T["range"] = range
	T["insert"] = insert
	T["pop"] = pop
end

--[[
local round = 0
local push_mean = 0
local pop_mean = 0
local round = round + 1
io.write("-- performance, round:" .. round)
io.write("\n")
max_count = 1000 * 1000 * 10
o = os.clock()
for i = 50, max_count + 50, 1 do
	lst:pushf(i)
end
t = os.clock() - o
push_mean = push_mean + t
print("push " .. max_count .. " cost " .. t)
o = os.clock()
while lst:count() > 0 do
	lst:popl()
end
t = os.clock() - o
pop_mean = pop_mean + t
print("pop  " .. max_count .. " cost " .. t)
]]
