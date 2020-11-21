.DEFAULT_GOAL= release
EXE:= moon
SRC:=
SRC_DIR:=
VENDOR:= lib ring
VENDOR+= uuid salt inspect lhutil lautil u-test sqlite3 csv json curler etlua
VENDOR+= list ffi_ammonia base64 blake3
VENDOR+= argparse lfs lpcap lpcode lpeg lpprint lpvm re
VENDOR_DIR:= lpeg_patterns lpeg_patterns/http cgilua lunajson
VENDOR_DIR+= moonscript moonscript/parse moonscript/compile moonscript/transform moonscript/cmd
MAKEFLAGS= --silent
CC= gcc
AR= gcc-ar
NM= gcc-nm
RANLIB= gcc-ranlib
CFLAGS= -pipe -ffunction-sections -fdata-sections -fomit-frame-pointer -flto -fuse-linker-plugin
CCOPT= -O3 -march=nehalem -mtune=haswell -msse4.2
LDFLAGS= -Wl,--gc-sections,--as-needed,--sort-common,--strip-all,-flto
include lib/tests.mk
include lib/std.mk
include lib/rules.mk
