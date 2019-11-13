code
===

Luaコード置き場

`{free,ours}/benches` 以下にはパフォーマンスのベンチマーク用コードが置いてある

```shell-session
$ luarocks --local install luasocket
$ lua benchmark.lua
 BATCH_SIZE:  1000
MEDIAN_SIZE:  1001
--- results (10^(-6) sec) ---
free    32.5234
ours    27.3726
$ QUOTIENT=4 BATCH_SIZE=10 MEDIAN_SIZE=1000 lua benchmark.lua
 BATCH_SIZE:    10
MEDIAN_SIZE:  1000
--- results (10^(-4) sec) ---
free    0.3011
ours    0.2394
```
