FNLC= bin/fennelc.lua
FNLC_T= bin/fennelc
FNL = bin/fennel.lua
FNL_T= bin/fennel
CLEAN+= clean_fennel

$(FNLC_T): $(LUA_T) $(LIBLUAJIT_A)
	$(ECHOT) CC $@
	$(CPR) vendor/lua/fennel/fennel.lua vendor/lua/cimicida.lua .
	CC=$(HOST_CC) NM=$(TARGET_NM) $(LUA_T) $(LUASTATIC) $(FNLC) cimicida.lua fennel.lua \
		 $(LIBLUAJIT_A) $(FLAGS) $(LDFLAGS) 2>&1 >/dev/null
	$(RM) $(RMFLAGS) cimicida.lua fennel.lua $(FNLC).c

$(FNL_T): $(FNLC_T)
	$(ECHOT) CC $@
	$(CPR) vendor/lua/fennel/fennel.lua .
	CC=$(HOST_CC) NM=$(TARGET_NM) $(LUA_T) $(LUASTATIC) $(FNL) fennel.lua $(LIBLUAJIT_A) $(FLAGS) $(LDFLAGS) 2>&1 >/dev/null
	$(RM) $(RMFLAGS) fennel.lua $(FNL).c

%.lua: $(FNLC_T) %.fnl
	$(FNLC_T) $*.fnl $@

clean_fennel:
	$(RM) $(RMFLAGS) $(COMPILED_FNL) $(FNLC_T) $(FNL_T) cimicida.lua
