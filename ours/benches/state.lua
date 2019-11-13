local eff = require('eff/src/eff')
local handler, inst, perform
handler = eff.handler
inst = eff.inst
perform = eff.perform

---

return function()
  local Get = inst()
  local get = function()
    return perform(Get)
  end

  local Modify = inst()
  local modify = function(f)
    return perform(Modify, f)
  end


  local run = function(init, th)
    local state = init

    return handler {
      val = function(x) return x end,
      [Get] = function(_, k)
        return k(state)
      end,
      [Modify] = function(c, k)
        state = c(state)
        return k()
      end
    }(th)
  end

  return {
    get = get,
    modify = modify,
    run = run
  }
end

