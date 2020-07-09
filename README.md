OmniaJIT
========

Fork of [Omnia](https://github.com/tongson/omnia), LuaJIT instead of PUC-Rio Lua.

Compile LuaJIT and Fennel source code into standalone executables. This makes it easy to use them for general purpose scripting.

Requires: GNU Make, a compiler and binutils (or equivalent). Installing development tools e.g. the package build-essential should have everything you need. Does not require autotools.<br/>
Note: Linux and OS X only. xBSD soon.

#### Getting started

1. Edit the following space delimited variables in the top-level Makefile<br/>
     MAIN: The "main" script in the `bin/` directory<br/>
     SRC: Modules that are specific to your application. Copy these to `src/lua`. <br/>
     SRC_DIR: Directories containing modules that are specific to your application. Copy these to `src/lua`.</br>
     VENDOR: 3rd party modules<br/>
     VENDOR_DIR: directories containing 3rd party modules<br/>

2. Copy the main source file into the `bin/` directory.

3. Copy modules into `src/lua/` or `vendor/lua/`.

The SRC, VENDOR split is just for organization. Underneath they are using the same Make routines.

1. Run `make`<br/>
If you want to link statically run `make STATIC=1`<br/>
During developlement or debugging run `make DEBUG=1`

2. The executable will be located under the `bin/` directory

#### Adding plain Lua and MoonScript modules. (NOTE: VENDOR and SRC are interchangeable.)

Adding plain modules is trivial. $(NAME) is the name of the module passed to `VENDOR`.

1. Copy the module to `vendor/lua/$(NAME).{lua,moon}`<br/>
  example: `cp ~/Downloads/dkjson.lua vendor/lua`
1. Add `$(NAME)` to `VENDOR`<br/>
  example: `VENDOR= re dkjson`

For modules that are split into multile files, such as Penlight:

1. Copy the directory of the Lua to `vendor/lua/$(NAME)`<br/>
  example: `cp -R ~/Download/Penlight-1.3.1/lua/pl vendor/lua`
1. Add `$(NAME)` to `VENDOR_DIR`<br/>
  example: `VENDOR_DIR= pl`

For modules with multiple levels of directories you will have to pass each directory. Example:<br/>
  `VENDOR_DIR= ldoc ldoc/builtin ldoc/html`

Lua does not have facilities to traverse directories and I'd like to avoid shell out functions.

#### Included projects

Project                                                     | Version             | License
------------------------------------------------------------|---------------------|---------
[LuaJIT](https://github.com/openresty/luajit2)              | v2.1-20200102       | MIT
[luastatic](https://github.com/ers35/luastatic)             | 0.0.4               | CC0

#### Available modules (Feel free to open a Github issue if you want help with adding a new Lua module.)

Module                                                            | Version         | License
------------------------------------------------------------------|-----------------|---------
[LPegLJ](https://github.com/sacek/LPegLJ)[1]                      | 1.0.0           | MIT
[luafilesystem](https://github.com/spacewander/luafilesystem)     | 0.3             | MIT
[u-test](https://github.com/IUdalov/u-test)                       | 113259f         | MIT
[luafun](https://github.com/luafun/luafun)                        | 04c99f9         | MIT
[argparse](https://github.com/luarocks/argparse)                  | 20c1445         | MIT
[ftcsv](https://github.com/FourierTransformer/ftcsv)              | 665f789 / 1.1.6 | MIT
[Fennel](https://github.com/bakpakin/Fennel/)                     | 0.1.1           | MIT
[moonscript](https://moonscript.org)                              | dba4b10         | MIT
[cliargs](https://github.com/amireh/lua_cliargs)                  | 820e2d2         | MIT
[tsv](https://github.com/cloudflarearchive/lua-resty-kyototycoon) | f51c0e0         | BSD
[dkjson](http://dkolf.de/src/dkjson-lua.fsl/home)                 | c23a5792f3      | MIT
[CBOR](https://framagit.org/fperrad/lua-ConciseSerialization)     | 0.2.2           | MIT
[salt](https://github.com/VaiN474/salt)                           | fa0d48f         | MIT
[funk](https://github.com/Wiladams/funk/)                         | 3aa9560         | MIT
[base64](https://github.com/iskolbin/lbase64/)                    | 6001688         | MIT
[LJSQLite3](https://github.com/stepelu/lua-ljsqlite3)             | d742002         | MIT
[xsys](https://github.com/stepelu/lua-xsys/)                      | 87df92c         | MIT
[templet](https://peter.colberg.org/lua-templet)                  | 38107395f8      | MIT
[inspect](https://github.com/kikito/inspect.lua)                  | b611db6         | MIT

[1] Renamed to lpeg. `require"lpeg"` to require it.<br/>
[2] lfs moved to `vendor/lua` so `require"lfs"` works.<br/>
