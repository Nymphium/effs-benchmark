local eff = require('ours/eff/src/eff')
local handler, inst, perform
handler = eff.handler
inst = eff.inst
perform = eff.perform

---

local Exception = inst()
local handle_exn = handler {
  val = function(i)
    return i
  end,
  [Exception] = function(arg, _)
    return arg
  end
}

local program = function(iter)
  for _ = 1, iter do
    handle_exn(function()
      return perform(Exception, 1)
    end)
  end
end

return program
