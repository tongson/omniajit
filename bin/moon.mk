.DEFAULT_GOAL= release
EXE:= moon
SRC:= 
SRC_DIR:=
VENDOR:= lib ring
VENDOR+= dkjson uuid salt base64 inspect lhutil
VENDOR+= argparse lfs lpcap lpcode lpeg lpprint lpvm
VENDOR_DIR:= moonscript moonscript/parse moonscript/compile moonscript/transform moonscript/cmd lpeg_patterns lpeg_patterns/http
MAKEFLAGS= --silent
CC= cc
CFLAGS= -O2 -march=nocona -mtune=haswell -msse4.2 -fomit-frame-pointer -pipe -ffunction-sections -fdata-sections -DNDEBUG
CCOPT=
LDFLAGS= -Wl,--strip-all -Wl,--gc-sections
include lib/tests.mk
include lib/std.mk
include lib/rules.mk
