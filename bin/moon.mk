.DEFAULT_GOAL= release
EXE:= moon
SRC:= 
SRC_DIR:=
VENDOR:= lib ring
VENDOR+= uuid salt base64 inspect lhutil lautil u-test sqlite3 ftcsv lunajson curler etlua
VENDOR+= argparse lfs lpcap lpcode lpeg lpprint lpvm
VENDOR_DIR:= moonscript moonscript/parse moonscript/compile moonscript/transform moonscript/cmd lpeg_patterns lpeg_patterns/http cgilua lunajson
MAKEFLAGS= --silent
CC= cc
CFLAGS= -O3 -march=nocona -mtune=haswell -msse4.2 -fomit-frame-pointer -pipe -ffunction-sections -fdata-sections
CCOPT=
LDFLAGS= -Wl,--strip-all -Wl,--gc-sections
include lib/tests.mk
include lib/std.mk
include lib/rules.mk
