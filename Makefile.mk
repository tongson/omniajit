.DEFAULT_GOAL= release
EXE:= 
SRC:= 
SRC_DIR:=
VENDOR:= 
VENDOR_DIR:=
MAKEFLAGS= --silent
CC= cc
CFLAGS= -Os -mtune=generic -mmmx -msse -msse2 -fomit-frame-pointer -pipe
CCOPT= 
LDFLAGS= -Wl,--strip-all
include lib/tests.mk
include lib/std.mk
include lib/rules.mk
