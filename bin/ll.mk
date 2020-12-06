.DEFAULT_GOAL= release
EXE:= ll
SRC:=
SRC_DIR:=
VENDOR:= std exec ffi_ext
VENDOR+= uuid lhutil lautil sqlite3 csv json curler etlua
VENDOR+= list ammonia base64 blake3
VENDOR+= lpcap lpcode lpeg lpprint lpvm re
VENDOR_DIR:= lpeg_patterns lpeg_patterns/http cgilua lunajson
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
