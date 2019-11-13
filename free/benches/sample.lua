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

local program do
  local t = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

  program = op.for_(t, function(v)
    return perform(Double, v) >> perform_(Write, Return)
  end)
end

local main = function()
  return run(handle(with_write(),
                    handle(with_double, program)
  ))
end

return {
  main = main
}
