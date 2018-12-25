.DEFAULT_GOAL= release
EXE:= luajit
SRC:=
SRC_DIR:=
VENDOR:= cimicida u-test fennel fun
VENDOR_DIR:=
MAKEFLAGS= --silent
HOST_CC= cc
CROSS=
CROSS_CC=
CCOPT= -Os -mtune=generic -mmmx -msse -msse2 -fomit-frame-pointer -pipe
LDFLAGS= -Wl,--strip-all
TARGET_CCOPT= $(CCOPT)
TARGET_CFLAGS= $(CFLAGS)
TARGET_LDFLAGS= $(LDFLAGS)
include lib/tests.mk
include lib/std.mk
include lib/rules.mk
