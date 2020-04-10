.POSIX:
.SUFFIXES:
NULSTRING:=
CONFIGURE_P:= lib/configure
INCLUDES_P:= -Ilib/luajit/src

# Append -static-libgcc to CFLAGS if GCC is detected.
IS_CC:= $(shell $(CONFIGURE_P)/test-cc.sh $(CC))
ifeq ($(IS_CC), GCC)
  CFLAGS+= -static-libgcc -lgcc_eh
endif

DEFINES+= -DNDEBUG
FLAGS:= $(DEFINES) $(INCLUDES_P) $(CFLAGS) $(CCOPT) $(CCWARN)
