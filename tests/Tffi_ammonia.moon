T = require "u-test"
ammonia = require "ffi_ammonia"
T["ffi_ammonia.clean"] = ->
    T.equal("XSS", ammonia.clean("XSS<script>attack</script>"))
T["ffi_ammonia.clean_test"] = ->
    T.equal("&lt;a&#32;href&#61;&apos;test&apos;&gt;Test&lt;&#47;a&gt;", ammonia.clean_text("<a href='test'>Test</a>"))


