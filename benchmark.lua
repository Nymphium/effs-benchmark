local gettime, sleep do
  local ok, socket = pcall(require, 'socket')

  if not ok then
    io.stderr:write(
      "'luasocket' is not installed." .. '\n' ..
      "Try `luarocks install --local luasocket`\n")
    os.exit(1)
  end

  gettime = socket.gettime
  sleep = socket.sleep
end

-- measurement {{{
local BATCH_SIZE = tonumber(os.getenv('BATCH_SIZE') or 200)
local MEDIAN_SIZE = tonumber(os.getenv('MEDIAN_SIZE') or 501)
local QUOTIENT = tonumber(os.getenv('QUOTIENT') or 6)

local measure1 = function(th)
  collectgarbage("collect")
  local t1 = gettime()
  th()
  local t2 = gettime()

  return t2 - t1
end

-- batch unit
local batch = function(th)
  local ret = 0.0

  for _ = 1, BATCH_SIZE do
    local t = measure1(th)
    ret = ret + t
  end

  return ret / BATCH_SIZE
end

local measure = function(th)
  -- batchの中央値を取る
  local results = {}

  for _ = 1, MEDIAN_SIZE do
    table.insert(results, batch(th))
  end

  if MEDIAN_SIZE % 2 == 0 then
    return results[(MEDIAN_SIZE + 1) / 2]
  else
    return (results[MEDIAN_SIZE / 2] + results[MEDIAN_SIZE / 2 + 1]) / 2
  end
end
-- }}}

local bench_app = function(app)
  -- warm up
  batch(app)

  return measure(app)
end

-- measure {{{
package.path = package.path
  .. ";./free/?.lua"
  .. ";./ours/?.lua"

local app_bench = function(path)
  local app = require(path).main

  return function()
    return { label = path, result = bench_app(app) }
  end
end

local mk_bench = function(label, fn, param)
  return function()
    return { label = label, result = bench_app(function() return fn(param) end) }
  end
end

local show = function(result)
  return ("%4.4f"):format(result * 10^QUOTIENT)
end

local print_result = function(res)
  print(res.label, show(res.result))
end

local run_benches = function(jobs)
  local results = {}

  print(([[
          BATCH_SIZE: %5d
         MEDIAN_SIZE: %5d]]):format(BATCH_SIZE, MEDIAN_SIZE))

  for _, job in ipairs(jobs) do
    sleep(1)
    table.insert(results, job())
  end

  print(("--- results (10^(%d) sec) ---"):format(-QUOTIENT))
  for _, result in ipairs(results) do
    print_result(result)
  end
end

-- }}}

--- main {{{
local freelooper = require('free/benches/looper')

run_benches {
  -- free
  -- "free/benches/sample",
  -- "free/benches/controls",
  -- "free/benches/morecontrols",
  mk_bench("free/loop5", freelooper, 10^5),
  -- "free/benches/onestate",
  -- "free/benches/multistate",
  -- ours
  -- "ours/benches/sample",
  -- "ours/benches/controls",
  -- "ours/benches/morecontrols",
  -- "ours/benches/for10_7",
  -- "ours/benches/onestate",
  -- "ours/benches/multistate",
}
-- }}}
