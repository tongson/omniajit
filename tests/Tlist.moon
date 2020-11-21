#!/usr/bin/env moon
lst = require("list").new()
T = require("u-test")

lst\pushl("b") -- push last 'b'
lst\pushf("a") -- push first 'a'

for i = 1, 4, 1
    lst\pushl(tostring(i)) -- push last '1, 2, 3, 4'

lst\pushl({5, 6, 7}) -- push table
lst\pushl(8) -- push number
lst\pushl(true) -- push boolean

lst\remove("3") -- remove '3', in middle
lst\popf() -- pop first 'a'

lst\pushl("end") -- push 'end'
lst\popl() -- pop 'end'

T["walk"] = ->
    for k, v in lst\walk()
        if k == 1 T.equal(v, "b")
        if k == 2 T.equal(v, "1")
        if k == 3 T.equal(v, "2")
        if k == 4 T.equal(v, "4")
        if k == 5 T.is_table(v)
        if k == 6 T.is_number(v)
        if k == 7 T.is_true(v)
T["range"] = ->
    for i, v in ipairs(lst\range(2, 3))
        if i == 1 T.equal(v, "1")
        if i == 2 T.equal(v, "2")
T["insert"] = ->
    lst\insertf("0", "1") -- insert front of '1'
    lst\insertl("3", "2") -- insert after of '2'
    for k, v in lst\walk()
        if k == 1 T.equal(v, "b")
        if k == 2 T.equal(v, "0")
        if k == 3 T.equal(v, "1")
        if k == 4 T.equal(v, "2")
        if k == 5 T.equal(v, "3")
        if k == 6 T.equal(v, "4")
        if k == 7 T.is_table(v)
        if k == 8 T.is_number(v)
        if k == 9 T.is_true(v)
T["pop"] = ->
    T.is_true(lst\popl())
    T.is_number(lst\popl())
    T.is_table(lst\popl())
    T.equal(lst\popl(), "4")
    T.equal(lst\popl(), "3")
    T.equal(lst\popl(), "2")
    T.equal(lst\popl(), "1")
    T.equal(lst\popl(), "0")
    T.equal(lst\popl(), "b")


round = 0
push_mean = 0
pop_mean = 0
round = round + 1
io.write("-- performance, round:" .. round)
io.write("\n")
max_count = 1000 * 1000 * 10
o = os.clock()
for i = 50, max_count + 50, 1
    lst\pushf(i)
t = os.clock() - o
push_mean = push_mean + t
print("push " .. max_count .. " cost " .. t)
o = os.clock()
while lst\count() > 0
    lst\popl()
t = os.clock() - o
pop_mean = pop_mean + t
print("pop  " .. max_count .. " cost " .. t)
