.DEFAULT_GOAL= release
EXE:= moon
SRC:=
SRC_DIR:=
VENDOR:= lib ring
VENDOR+= lunajson dkjson
VENDOR+= argparse lfs lpcap lpcode lpeg lpprint lpvm
VENDOR_DIR:= moonscript moonscript/parse moonscript/compile moonscript/transform moonscript/cmd lunajson
#MAKEFLAGS= --silent
CC= gcc
AR= gcc-ar
NM= gcc-nm
RANLIB= gcc-ranlib
CFLAGS= -pipe -ffunction-sections -fdata-sections -flto -fuse-linker-plugin
CCOPT= -O3 -march=nehalem -mtune=haswell -msse4.2 -fomit-frame-pointer
LDFLAGS= -Wl,--gc-sections,--as-needed,--sort-common,--strip-all,-flto
include lib/tests.mk
include lib/std.mk
include lib/rules.mk
