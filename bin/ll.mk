.DEFAULT_GOAL= release
EXE:= ll
SRC:=
SRC_DIR:=
VENDOR:= std exec ffi_ext
VENDOR+= uuid inspect lhutil lautil u-test sqlite3 csv json etlua ahsm yaml cbor
VENDOR+= list web base64 blake3 redis hmac validation
VENDOR+= argparse lfs lpcap lpcode lpeg lpprint lpvm re
VENDOR_DIR:= lpeg_patterns lpeg_patterns/http lunajson validation
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
