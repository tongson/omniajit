local L = require("lfs")
local x, y = L.currentdir()
return print(x, y)