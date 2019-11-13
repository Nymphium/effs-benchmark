#!/usr/bin/bash

lua=${LUA:-lua}
version=3
if [[ "${lua}" == "luajit" ]]; then
  version=1
fi

luarocks5x="luarocks --lua-version 5.${version}"

LUA_PATH="$(${luarocks5x} path --lr-path);./?.lua" LUA_CPATH="$(${luarocks5x} path --lr-cpath);./?.lua" "${lua}" benchmark.lua
