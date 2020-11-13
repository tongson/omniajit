T = require "u-test"
ammonia = require "ffi_ammonia"
print (ammonia.clean("XSS<script>attack</script>"))
print (ammonia.clean_text("<a href='test'>Test</a>"))


