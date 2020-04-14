.DEFAULT_GOAL= release
EXE:= moon
SRC:= 
SRC_DIR:=
VENDOR:= lib ring
VENDOR+= dkjson uuid salt base64 inspect
VENDOR+= argparse lfs lpcap lpcode lpeg lpprint lpvm
VENDOR_DIR:= moonscript moonscript/parse moonscript/compile moonscript/transform moonscript/cmd
MAKEFLAGS= --silent
CC= cc
CFLAGS= -Os -mtune=generic -mmmx -msse -msse2 -fomit-frame-pointer -pipe -ffunction-sections -fdata-sections
CCOPT=
LDFLAGS= -Wl,--strip-all -Wl,--gc-sections
include lib/tests.mk
include lib/std.mk
include lib/rules.mk
