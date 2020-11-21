#!/usr/bin/env moon
lj = require 'json'

test = (round) ->
    saxtbl = {}
    bufsize = round == 1 and 64 or 1

    fp = io.open('json.dat')
    input = ->
        s = fp\read(bufsize)
        if not s
            fp\close()
            fp = nil
        return s
    parser = lj.newparser(input, saxtbl)

    if (parser.tryc() != string.byte('a'))
        print(parser.tryc())
        return "1st not a"
    if (parser.read(3) != ("abc"))
        return "not abc"
    if (parser.read(75) != ("abcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabc"))
        return "not abc*25"
    if (parser.tellpos() != 79)
        return "not read 78"
    parser.run()
    if parser.tellpos() != 139
        return "1st json not end at 139"
    if parser.read(8) != "  mmmmmm"
        return "not __mmmmmm"
    parser.run()
    if parser.tryc() != string.byte('&')
        return "not &"
    if parser.read(200) != '&++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
        return "not &+*"
    if parser.tellpos() != 276
        print(parser.tellpos())
        return "not last pos"
    if parser.tryc()
        return "not ended"
    if parser.read(10) != ""
        return "not empty"
    if parser.tellpos() != 276
        return "last pos moving"


io.write('parse: ')
for round = 1, 2
    err = test(round)
    if err
        io.write(err .. '\n')
        return true
    else
        io.write('ok\n')
        return false
