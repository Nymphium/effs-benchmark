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

local free = {
  looper = require('free/benches/looper'),
  same_fringe = require('free/benches/same_fringe'),
  state1 = require('free/benches/onestate'),
  multistate = require('free/benches/multistate'),
}

local ours = {
  looper = require('ours/benches/looper'),
  same_fringe = require('ours/benches/same_fringe'),
  state1 = require('ours/benches/onestate'),
  multistate = require('ours/benches/multistate'),
}

local native = {
  same_fringe = require('coroutine/same_fringe')
}

---- looper {{{
run_benches {
  -- free
  mk_bench("free/looper1", free.looper, 10^5 * 1),
  mk_bench("free/looper2", free.looper, 10^5 * 2),
  mk_bench("free/looper3", free.looper, 10^5 * 3),
  mk_bench("free/looper4", free.looper, 10^5 * 4),
  mk_bench("free/looper5", free.looper, 10^5 * 5),
  -- ours
  mk_bench("ours/looper1", ours.looper, 10^5 * 1),
  mk_bench("ours/looper2", ours.looper, 10^5 * 2),
  mk_bench("ours/looper3", ours.looper, 10^5 * 3),
  mk_bench("ours/looper4", ours.looper, 10^5 * 4),
  mk_bench("ours/looper5", ours.looper, 10^5 * 5),
}
-- }}}

---- same_fringe {{{
run_benches {
  -- free
  mk_bench("free/same_fringe1", free.same_fringe, 10^4 * 1),
  mk_bench("free/same_fringe2", free.same_fringe, 10^4 * 2),
  mk_bench("free/same_fringe3", free.same_fringe, 10^4 * 3),
  mk_bench("free/same_fringe4", free.same_fringe, 10^4 * 4),
  mk_bench("free/same_fringe5", free.same_fringe, 10^4 * 5),
  -- ours
  mk_bench("ours/same_fringe1", ours.same_fringe, 10^4 * 1),
  mk_bench("ours/same_fringe2", ours.same_fringe, 10^4 * 2),
  mk_bench("ours/same_fringe3", ours.same_fringe, 10^4 * 3),
  mk_bench("ours/same_fringe4", ours.same_fringe, 10^4 * 4),
  mk_bench("ours/same_fringe5", ours.same_fringe, 10^4 * 5),

  -- coroutine
  mk_bench("coroutine/same_fringe1", native.same_fringe, 10^4 * 1),
  mk_bench("coroutine/same_fringe2", native.same_fringe, 10^4 * 2),
  mk_bench("coroutine/same_fringe3", native.same_fringe, 10^4 * 3),
  mk_bench("coroutine/same_fringe4", native.same_fringe, 10^4 * 4),
  mk_bench("coroutine/same_fringe5", native.same_fringe, 10^4 * 5),
}
-- }}}

---- state {{{
run_benches {
  -- free
  mk_bench("free/state1", free.state1, 10^5 * 1),
  mk_bench("free/state2", free.state1, 10^5 * 2),
  mk_bench("free/state3", free.state1, 10^5 * 3),
  mk_bench("free/state4", free.state1, 10^5 * 4),
  mk_bench("free/state5", free.state1, 10^5 * 5),
  -- ours
  mk_bench("ours/state1", ours.state1, 10^5 * 1),
  mk_bench("ours/state2", ours.state1, 10^5 * 2),
  mk_bench("ours/state3", ours.state1, 10^5 * 3),
  mk_bench("ours/state4", ours.state1, 10^5 * 4),
  mk_bench("ours/state5", ours.state1, 10^5 * 5),
}
-- }}}

---- multistate {{{
run_benches {
  -- free
  mk_bench("free/mutistate1", free.multistate, 10 * 1),
  mk_bench("free/mutistate2", free.multistate, 10 * 2),
  mk_bench("free/mutistate3", free.multistate, 10 * 3),
  mk_bench("free/mutistate4", free.multistate, 10 * 4),
  mk_bench("free/mutistate5", free.multistate, 10 * 5),
  -- not enough memory / stack overflow
  -- mk_bench("free/mutistate", free.multistate, 10^4),

  -- ours
  mk_bench("ours/mutistate1", ours.multistate, 10 * 1),
  mk_bench("ours/mutistate2", ours.multistate, 10 * 2),
  mk_bench("ours/mutistate3", ours.multistate, 10 * 3),
  mk_bench("ours/mutistate4", ours.multistate, 10 * 4),
  mk_bench("ours/mutistate5", ours.multistate, 10 * 5),
  -- mk_bench("ours/mutistate6", ours.multistate, 10^2 * 6),
  -- not enough memory / stack overflow
  -- mk_bench("ours/mutistate", ours.multistate, 10^3),
}
-- }}}
