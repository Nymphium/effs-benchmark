local free = require('free')
local Return, Call, op
Return = free.Return
Call = free.Call
op = free.op

local eff = require('free_eff')
local handle, run, inst, perform, perform_
handle = eff.handle
run = eff.run
inst = eff.inst
perform = eff.perform
perform_ = eff.perform_

-----

local Double = inst()
local Write = inst()

local with_double = {
  val = Return,
  [Double] = function(x, k)
    return k(x * x)
  end
}

local with_write = function()
  local t = {}

  return {
    val = function(_)
      for _, v in ipairs(t) do
        -- print(v)
      end

      return Return()
    end,
    [Write] = function(v, k)
      table.insert(t, v)
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

local program = function(incr)
  return step_incr(1, incr, function(v)
    return perform(Write, v)
  end)
end

return function(incr)
  return run(handle(with_write(), program(incr)))
end

