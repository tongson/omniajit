T = require "u-test"
ammonia = require "ffi_ammonia"
T.equal("XSS", ammonia.clean("XSS<script>attack</script>"))
T.equal("", ammonia.clean_text("<a href='test'>Test</a>"))


