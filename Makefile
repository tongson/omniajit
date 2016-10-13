EXE:= test
SRC:= src moon_src
SRC_DIR:= moon
VENDOR:= cwtest lfs syscall
VENDOR_DIR:= syscall syscall/shared syscall/osx syscall/bsd syscall/linux syscall/linux/x64
MAKEFLAGS= --silent
HOST_CC=
CC= cc
CROSS=
CROSS_CC=
CCOPT= -Os -mtune=generic -mmmx -msse -msse2 -fomit-frame-pointer -pipe
CFLAGS+= -ffunction-sections -fdata-sections
LDFLAGS= -Wl,--gc-sections -Wl,--strip-all -Wl,--relax -Wl,--sort-common
ljDEFINES:=
TARGET_CCOPT= $(CCOPT)
TARGET_CFLAGS= $(CFLAGS)
TARGET_LDFLAGS= $(LDFLAGS)
include aux/tests.mk
include aux/std.mk
include aux/rules.mk
