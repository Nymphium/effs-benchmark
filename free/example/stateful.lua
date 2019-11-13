local free = require('free')
local Return, Call, op
Return = free.Return
Call = free.Call
op = free.op

local eff = require('free_eff')
local handle, handler, run, inst, perform, perform_
handle = eff.handle
handler = eff.handler
run = eff.run
inst = eff.inst
perform = eff.perform
perform_ = eff.perform_


-----


local State = function()
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

    local h = handler {
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

return {
  main = function()
    local SIZE = 1000

    local s do
      s = {}

      for i = 1, SIZE do
        s[i] = State()
      end
    end

    local program = s[1].get() >> function(a)
             return s[1].get() >> function(a)
             return s[1].get() >> function(a)
             return s[1].get() >> function(a)
             return s[1].get() >> function(a)
             return s[1].get() >> function(a)
             return s[1].get() >> function(a)
             return s[1].get() >> function(a)
             return s[1].get() >> function(a)
             return s[1].get() >> function(a)
             return s[1].get() >> function(a)
             return s[2].get() >> function(b)
             return s[3].modify(function(c)
               return a + b + c
             end) >> function(_)
             return s[3].get() >> function(c)
             return s[4].get() >> function(d)
             return s[5].get() >> function(e)
             return s[6].modify(function(f)
               return d + e + f
             end) >> function(_)
             return s[6].get() >> function(f)
             return s[7].get() >> function(g)
             return s[8].get() >> function(h)
             return s[9].get() >> function(i)
             return s[10].get() >> function(j)
             return s[10].get() >> function(j)
             return s[10].get() >> function(j)
             return s[10].get() >> function(j)
             return s[10].get() >> function(j)
             return s[10].get() >> function(j)
             return s[10].get() >> function(j)
             return s[10].get() >> function(j)
             return s[10].get() >> function(j)
             return s[10].get() >> function(j)
             return Return(a + b + c + d + e + f + g + h + i)
    end end end end end end end end end end end end
    end end end end end end end end end end
    end end end end end end end end end

    local p = program
    for i = 1, SIZE do
      p = s[i].run(i, p)
    end

    return run(p)
  end
}

-- print(run(p))
