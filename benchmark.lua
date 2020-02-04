local gettime, sleep do -- {{{
  local ok, socket = pcall(require, 'socket')

  if not ok then
    io.stderr:write(
      "'luasocket' is not installed." .. '\n' ..
      "Try `luarocks install --local luasocket`\n")
    os.exit(1)
  end

  gettime = socket.gettime
  sleep = socket.sleep
end -- }}}

-- measurement {{{
local BATCH_SIZE = tonumber(os.getenv('BATCH_SIZE') or 200)
local MEDIAN_SIZE = tonumber(os.getenv('MEDIAN_SIZE') or 501)
local QUOTIENT = tonumber(os.getenv('QUOTIENT') or 0)

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
  batch(th)

  for _ = 1, MEDIAN_SIZE do
    local r = batch(th)
    table.insert(results, r)
  end

  if MEDIAN_SIZE % 2 == 1 then
    return assert(results[(MEDIAN_SIZE + 1) / 2])
  else
    return (
          assert(results[MEDIAN_SIZE / 2])
        + assert(results[MEDIAN_SIZE / 2 + 1])
    ) / 2
  end
end
-- }}}


local mk_bench = function(label, fn, param)
  return function()
    return { label = label, result = measure(function() return fn(param) end) }
  end
end

local show = function(result)
  return ("%4.4f"):format(result * 10^QUOTIENT)
end

local print_result = function(res)
  print(res.label, show(res.result))
  io.stdout:flush()
end

local run_benches = function(jobs)
  local results = {}

  print(([[
          BATCH_SIZE: %5d
         MEDIAN_SIZE: %5d]]):format(BATCH_SIZE, MEDIAN_SIZE))
  io.stdout:flush()

  for _, job in ipairs(jobs) do
    sleep(1)
    table.insert(results, job())
  end

  print(("--- results (10^(%d) sec) ---"):format(-QUOTIENT))
  io.stdout:flush()
  for _, result in ipairs(results) do
    print_result(result)
  end
end

-----

local sorts = {
  free = {
    looper = require('free/benches/looper'),
    same_fringe = require('free/benches/same_fringe'),
    state1 = require('free/benches/onestate'),
    multistate = require('free/benches/multistate'),
    exception = require('free/benches/exception'),
  },
  ours = {
    looper = require('ours/benches/looper'),
    same_fringe = require('ours/benches/same_fringe'),
    state1 = require('ours/benches/onestate'),
    multistate = require('ours/benches/multistate'),
    exception = require('ours/benches/exception'),
  },
  native = {
    same_fringe = require('native/same_fringe'),
    exception = require('native/exception'),
  }
}

-- --[==[
---- looper {{{
run_benches {
  -- free
  mk_bench("free/looper1", sorts.free.looper, 10^5 * 1),
  mk_bench("free/looper2", sorts.free.looper, 10^5 * 2),
  mk_bench("free/looper3", sorts.free.looper, 10^5 * 3),
  mk_bench("free/looper4", sorts.free.looper, 10^5 * 4),
  mk_bench("free/looper5", sorts.free.looper, 10^5 * 5),
  -- ours
  mk_bench("ours/looper1", sorts.ours.looper, 10^5 * 1),
  mk_bench("ours/looper2", sorts.ours.looper, 10^5 * 2),
  mk_bench("ours/looper3", sorts.ours.looper, 10^5 * 3),
  mk_bench("ours/looper4", sorts.ours.looper, 10^5 * 4),
  mk_bench("ours/looper5", sorts.ours.looper, 10^5 * 5),
-- }}}

---- same_fringe {{{
  -- free
  mk_bench("free/same_fringe1", sorts.free.same_fringe, 10^4 * 1),
  mk_bench("free/same_fringe2", sorts.free.same_fringe, 10^4 * 2),
  mk_bench("free/same_fringe3", sorts.free.same_fringe, 10^4 * 3),
  mk_bench("free/same_fringe4", sorts.free.same_fringe, 10^4 * 4),
  mk_bench("free/same_fringe5", sorts.free.same_fringe, 10^4 * 5),
  -- ours
  mk_bench("ours/same_fringe1", sorts.ours.same_fringe, 10^4 * 1),
  mk_bench("ours/same_fringe2", sorts.ours.same_fringe, 10^4 * 2),
  mk_bench("ours/same_fringe3", sorts.ours.same_fringe, 10^4 * 3),
  mk_bench("ours/same_fringe4", sorts.ours.same_fringe, 10^4 * 4),
  mk_bench("ours/same_fringe5", sorts.ours.same_fringe, 10^4 * 5),

  -- native
  mk_bench("native/same_fringe1", sorts.native.same_fringe, 10^4 * 1),
  mk_bench("native/same_fringe2", sorts.native.same_fringe, 10^4 * 2),
  mk_bench("native/same_fringe3", sorts.native.same_fringe, 10^4 * 3),
  mk_bench("native/same_fringe4", sorts.native.same_fringe, 10^4 * 4),
  mk_bench("native/same_fringe5", sorts.native.same_fringe, 10^4 * 5),
-- }}}

---- state {{{
  -- free
  mk_bench("free/state1", sorts.free.state1, 10^5 * 1),
  mk_bench("free/state2", sorts.free.state1, 10^5 * 2),
  mk_bench("free/state3", sorts.free.state1, 10^5 * 3),
  mk_bench("free/state4", sorts.free.state1, 10^5 * 4),
  mk_bench("free/state5", sorts.free.state1, 10^5 * 5),
  -- ours
  mk_bench("ours/state1", sorts.ours.state1, 10^5 * 1),
  mk_bench("ours/state2", sorts.ours.state1, 10^5 * 2),
  mk_bench("ours/state3", sorts.ours.state1, 10^5 * 3),
  mk_bench("ours/state4", sorts.ours.state1, 10^5 * 4),
  mk_bench("ours/state5", sorts.ours.state1, 10^5 * 5),
-- }}}

---- multistate {{{
  -- free
  mk_bench("free/mutistate1", sorts.free.multistate, 10 * 1),
  mk_bench("free/mutistate2", sorts.free.multistate, 10 * 2),
  mk_bench("free/mutistate3", sorts.free.multistate, 10 * 3),
  mk_bench("free/mutistate4", sorts.free.multistate, 10 * 4),
  mk_bench("free/mutistate5", sorts.free.multistate, 10 * 5),
  -- not enough memory / stack overflow
  -- mk_bench("free/mutistate", sorts.free.multistate, 10^4),

  -- ours
  mk_bench("ours/mutistate1", sorts.ours.multistate, 10 * 1),
  mk_bench("ours/mutistate2", sorts.ours.multistate, 10 * 2),
  mk_bench("ours/mutistate3", sorts.ours.multistate, 10 * 3),
  mk_bench("ours/mutistate4", sorts.ours.multistate, 10 * 4),
  mk_bench("ours/mutistate5", sorts.ours.multistate, 10 * 5),
  -- mk_bench("ours/mutistate6", sorts.ours.multistate, 10^2 * 6),
  -- not enough memory / stack overflow
  -- mk_bench("ours/mutistate", ours.multistate, 10^3),
}
-- }}}
-- --]==]

---- exception {{{
do
  local benches = {}
  local basic_size = 10^4

  for _, key in ipairs{"ours", "free", "native"} do
    for i = 1, 5 do
      table.insert(benches, mk_bench(("%s/exception%d"):format(key, i), sorts[key].exception, basic_size * i))
    end
  end

  run_benches(benches)
end
---- }}}
