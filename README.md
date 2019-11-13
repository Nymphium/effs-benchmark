eff benchmarks
===

This repository compares two algebraic effects implementations: with free monad and coroutines, in Lua language.

```console
$ git submodule update --init
$ luarocks --local install luasocket
$ ./run.bash
```

## env
### `BATCH_SIZE`
### `MEDIAN_SIZE`
### `LUA`
Specify lua implementation. `lua` is default.
If you want to use LuaJIT then specify `luajit` like `LUA=luajit ./run.bash`.
