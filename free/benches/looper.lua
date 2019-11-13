local eff = require('free/free_eff')
local handle, run, inst, perform
handle = eff.handle
run = eff.run
inst = eff.inst
perform = eff.perform

local free = eff.free
local Return, op
Return = free.Return
op = free.op

-----

local Log = inst()
local log = function(msg)
  return perform(Log, msg)
end

local collect_log_handler = function()
  local msgs = {}

  return {
    val = function(v)
      return Return({v, msgs})
    end,
    [Log] = function(msg, k)
      table.insert(msgs, msg)
      return k()
    end
  }
end

-- int -> int -> (int -> unit computation) -> unit computation
local step_incr = function(from, to, f)
  local function step(i)
      return op.bind(f(i), function(_)
        if i == to then
          return Return()
        else
          return step(i + 1)
        end
    end)
  end

  return step(from)
end

local program = function(iter)
  return step_incr(1, iter, log)
end

return function(iter)
  assert(#(run(handle(collect_log_handler(), program(iter)))[2]) == iter)
end

