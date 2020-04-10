.DEFAULT_GOAL= release
EXE:= moon
SRC:= 
SRC_DIR:=
VENDOR:= lib ring cliargs argparse lfs tsv dkjson ftcsv uuid CBOR salt funk u-test base64 inspect templet xsys sqlite3 lpcap lpcode lpeg lpprint lpvm
VENDOR_DIR:= cliargs cliargs/utils moonscript moonscript/parse moonscript/compile moonscript/transform moonscript/cmd
MAKEFLAGS= --silent
CC= cc
CFLAGS= -Os -mtune=generic -mmmx -msse -msse2 -fomit-frame-pointer -pipe
CCOPT=
LDFLAGS= -Wl,--strip-all
include lib/tests.mk
include lib/std.mk
include lib/rules.mk
