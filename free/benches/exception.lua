local eff = require('free/free_eff')
local handle, run, inst, perform
handle = eff.handle
run = eff.run
inst = eff.inst
perform = eff.perform
local Return = eff.free.Return

local Exception = inst()

local handle_exn = {
  val = function(i)
    return Return(i)
  end,
  [Exception] = function(arg, _)
    return Return(arg)
  end
}

return function(iter)
  for _ = 1, iter do
    run(handle(handle_exn, perform(Exception, 1)))
  end
end
