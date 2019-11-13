local eff = require('free/free_eff')
local handle, run, inst, perform, perform_
handle = eff.handle
run = eff.run
inst = eff.inst
perform = eff.perform
perform_ = eff.perform_

local free = eff.free
local Return, Call, op
Return = free.Return
Call = free.Call
op = free.op



-----

return function()
  local Get = inst()
  local get = function()
    return perform(Get, nil)
  end

  local Modify = inst()
  local modify = function(f)
    return perform(Modify, f)
  end


  local run = function(init, e)
    local state = init

    local h = {
      val = Return,
      [Get] = function(_, k)
        return k(state)
      end,
      [Modify] = function(f, k)
        state = f(state)
        return k()
      end
    }

    return handle(h, e)
  end

  return {
    get = get,
    modify = modify,
    run = run
  }
end

