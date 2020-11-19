#!/usr/bin/env moon
T = require "u-test"

./Tbase64.moon
echo " base64 module tested."
read -n1 -p " Press any key to continue..."
clear

./Tcsv.moon
echo " ftcsv module tested."
read -n1 -p " Press any key to continue..."
clear

./Tescape_sql.moon
echo " lib.exec.escape_sql function tested."
read -n1 -p " Press any key to continue..."
clear

./Tjson.moon
echo " lunajson module tested."
read -n1 -p " Press any key to continue..."
clear

./Tlhutil.moon
echo " lua-http/util tested."
read -n1 -p " Press any key to continue..."
clear

./Tsqlite3.moon
echo " LJSQLite3 module tested."
read -n1 -p " Press any key to continue..."
clear

./stdin.sh
echo " STDIN to script tested."
read -n1 -p " Press any key to continue..."
clear

./Tuuid.moon
echo " uuid module tested."
read -n1 -p " Press any key to continue..."
clear

./Tcurler.moon
echo " curler module tested."
read -n1 -p " Press any key to continue..."
clear

./Tetlua.moon
echo " etlua module tested."
read -n1 -p " Press any key to continue..."
clear

moon moonscript/* && { echo "Ok."; }
echo " Partial MoonScript language tests done."
read -n1 -p " Press any key to continue..."
clear

./Tmoon_module.moon
echo " MoonScript module tested."


