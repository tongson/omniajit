MOONC_T= bin/moonc
MOONI_T= bin/mooni
MOONC= bin/moonc.lua
MOONI= bin/mooni.lua
MOONSCRIPT= moonscript/*.lua moonscript/parse/*.lua moonscript/compile/*.lua moonscript/transform/*.lua
LPEGLJ= lpcap.lua	lpcode.lua lpeg.lua lpprint.lua	lpvm.lua
CLEAN+= clean_moonscript

$(MOONC_T): $(LUAJIT_A) $(LUA_T)
	$(E) "CC        $@"
	for d in $(LPEGLJ) moonscript cimicida.lua ; do cp -R vendor/lua/$$d . ; done
	CC=$(CC) NM=$(NM) $(LUA_T) $(LUASTATIC) $(MOONC) cimicida.lua $(MOONSCRIPT) $(LPEGLJ) \
		 $(LUAJIT_A) -Iaux/luajit/src $(HOST_FLAGS) $(LDFLAGS) 2>&1 >/dev/null
	$(RM) $(RMFLAGS) cimicida.lua $(LPEGLJ) $(MOONC).c
	$(RMRF) moonscript

$(MOONI_T): $(MOONC_T)
	$(E) "CC        $@"
	for d in $(LPEGLJ) moonscript; do cp -R vendor/lua/$$d . ; done
	CC=$(CC) NM=$(NM) $(LUA_T) $(LUASTATIC) $(MOONI) $(MOONSCRIPT) $(LPEGLJ) \
		 $(LUAJIT_A) -Iaux/luajit/src $(HOST_FLAGS) $(LDFLAGS) 2>&1 >/dev/null
	$(RM) $(RMFLAGS) cimicida.lua $(MOONI).c
	$(RMRF) moonscript

%.lua: $(MOONC_T) %.moon
	$(MOONC_T) $*.moon $@

clean_moonscript:
	$(RM) $(RMFLAGS) $(COMPILED) $(MOONC_T) $(MOONI_T) $(LPEGLJ)
