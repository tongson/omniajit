$(LUA_T):
	$(E) "CC        $@"
	$(CC) -o $@ -Iaux/lua -DMAKE_LUA -DLUA_USE_POSIX $(HOST_FLAGS) $(ONE).c -lm

$(LUAJIT_A):
	$(MAKE) -C aux/luajit/src \
		HOST_CC="$(HOST_CC)" \
		TARGET_CFLAGS="$(TARGET_CFLAGS)" \
		TARGET_LD="$(TARGET_LD)" \
		TARGET_LDFLAGS="$(TARGET_LDFLAGS)" \
		TARGET_STCC="$(TARGET_STCC)" \
		TARGET_DYNCC="$(TARGET_DYNCC)" \
		TARGET_CC="$(TARGET_CC)" \
		TARGET_AR="$(TARGET_AR) rcs" \
		XCFLAGS="$(ljDEFINES)" libluajit.a "LJCORE_O=ljamalg.o"

$(MODULES):
	$(E) "CP        MODULES"
	for f in $(VENDOR); do $(CP) $(VENDOR_P)/$$f.lua .; done
	for f in $(SRC); do $(CP) $(SRC_P)/$$f.lua .; done

$(SRC_LUA):
	for d in $(SRC_DIRS); do [ -d $$d ] || $(CPR) $(SRC_P)/$$d .; done

$(VENDOR_LUA):
	for d in $(VENDOR_DIRS); do [ -d $$d ] || $(CPR) $(VENDOR_P)/$$d .; done

$(EXE_T): $(BUILD_DEPS) $(LUAJIT_A) $(LUA_T) $(COMPILED) $(MODULES) $(SRC_LUA) $(VENDOR_LUA)
	$(E) "LN        $(EXE_T)"
	CC=$(TARGET_STCC) NM=$(TARGET_NM) $(LUA_T) $(LUASTATIC) $(MAIN) $(SRC_LUA) $(VENDOR_LUA) $(MODULES) $(LUAJIT_A) \
	  $(TARGET_FLAGS) $(PIE) $(TARGET_LDFLAGS) 2>&1 >/dev/null
	$(RM) $(RMFLAGS) $(MAIN).c $(MODULES)
	$(RMRF) $(VENDOR_DIRS) $(SRC_DIRS)

clean: $(CLEAN)
	$(ECHO) "Cleaning up..."
	$(RM) $(RMFLAGS) $(MAIN).c $(LUA_O) $(LUA_T) $(LUAC_T) $(LUA_A) $(EXE_T) $(LUA_A) $(LUA_O) $(LUAJIT_A) $(COMPILED) $(MODULES)
	$(RMRF) $(SRC_DIRS) $(VENDOR_DIRS)
	$(MAKE) -C aux/luajit/src clean
	$(ECHO) "Done!"

new:
	$(RMRF) vendor/lua/* vendor/c/* src/lua/* src/c/* bin/test.moon Makefile
	$(CP) aux/Makefile.pristine Makefile

