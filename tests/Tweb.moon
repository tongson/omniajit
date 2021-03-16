#!../bin/moon
arg.path = {}
arg.path.ffi = '.'
T = require "u-test"
web = require 'web'
T["web.clean"] = ->
    T.equal("XSS", web.clean("XSS<script>attack</script>"))
T["web.clean_text"] = ->
    T.equal("&lt;a&#32;href&#61;&apos;test&apos;&gt;Test&lt;&#47;a&gt;", web.clean_text("<a href='test'>Test</a>"))


