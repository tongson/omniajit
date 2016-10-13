.POSIX:
.SUFFIXES:
NULSTRING:=
CONFIGURE_P:= aux/configure
INCLUDES:= -Iaux/luajit/src
ifeq ($(CROSS),)
  CROSS:= $(NULSTRING)
endif
ifeq ($(HOST_CC),)
  HOST_CC:= $(CC)
endif
ifeq ($(CROSS_CC),)
  CROSS_CC:= $(HOST_CC)
endif
LD= ld
NM= nm
AR= ar
RANLIB= ranlib
STRIP= strip
TARGET_DYNCC= $(CROSS)$(CROSS_CC) -fPIC
TARGET_CC= $(CROSS)$(CROSS_CC) -fPIC
TARGET_STCC= $(CROSS)$(CROSS_CC)
TARGET_LD= $(CROSS)$(LD)
TARGET_AR= $(CROSS)$(AR)
TARGET_NM= $(CROSS)$(NM)
TARGET_STRIP= $(CROSS)$(STRIP)
TARGET_RANLIB= $(CROSS)$(RANLIB)

# FLAGS when compiling for an OpenWRT target.
IS_OPENWRT:= $(findstring openwrt,$(TARGET_STCC))
ifneq (,$(IS_OPENWRT))
  TARGET_CCOPT:= -Os -fomit-frame-pointer -msse -pipe -fno-asynchronous-unwind-tables -fno-unwind-tables
endif

# Append -static-libgcc to CFLAGS if GCC is detected.
IS_CC:= $(shell $(CONFIGURE_P)/test-cc.sh $(TARGET_STCC))
ifeq ($(IS_CC), GCC)
  TARGET_CFLAGS+= -static-libgcc -lgcc_eh
endif

IS_APPLE:= $(shell $(CONFIGURE_P)/test-mac.sh $(TARGET_STCC))
ifeq ($(IS_APPLE), APPLE)
  LDFLAGS:= -pagezero_size 10000 -image_base 100000000
  TARGET_LDFLAGS:= -pagezero_size 10000 -image_base 100000000
endif

# Test for GCC LTO capability.
ifeq ($(shell $(CONFIGURE_P)/test-gcc47.sh $(TARGET_STCC)), true)
  ifeq ($(shell $(CONFIGURE_P)/test-binutils-plugins.sh $(CROSS)gcc-ar), true)
    TARGET_CFLAGS+= -fwhole-program -flto -fuse-linker-plugin
    TARGET_LDFLAGS+= -fwhole-program -flto
    TARGET_RANLIB:= $(CROSS)gcc-ranlib
    TARGET_AR:= $(CROSS)gcc-ar
    TARGET_NM:= $(CROSS)gcc-nm
  endif
endif

### Lua Module specific defines and tests ####

## lpeg
ifeq ($(DEBUG), 1)
  lpegDEFINES= -DLPEG_DEBUG
endif

ifeq ($(DEBUG), 1)
  CCWARN:= -Wall -Wextra -Wdeclaration-after-statement -Wredundant-decls -Wshadow -Wpointer-arith
  TARGET_CFLAGS:= $(CCWARN) -O1 -fno-omit-frame-pointer -g
  TARGET_CCOPT:= $(NULSTRING)
  TARGET_LDFLAGS:= $(NULSTRING)
  MAKEFLAGS:= $(NULSTRING)
else
  DEFINES+= -DNDEBUG
endif

ifeq ($(STATIC), 1)
  PIE:= $(NULSTRING)
  TARGET_LDFLAGS+= -static
else
  ifneq ($(IS_CC), CLANG)
    PIE:= -fPIE -pie
  else
    PIE:= -fPIE -Wl,-pie
  endif
endif

ifeq ($(ASAN), 1)
  TARGET_CFLAGS:= -fsanitize=address -O1 -fno-omit-frame-pointer -g
  TARGET_CCOPT:= $(NULSTRING)
  TARGET_LDFLAGS:= $(NULSTRING)
  MAKEFLAGS:= $(NULSTRING)
endif

TARGET_FLAGS:= $(DEFINES) $(INCLUDES) $(TARGET_CFLAGS) $(TARGET_CCOPT) $(CCWARN) -ldl
HOST_FLAGS:= $(CFLAGS) $(CCOPT) $(CCWARN)
