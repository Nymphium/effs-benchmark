local eff = require('free/free_eff')
local handle, run, inst, perform
handle = eff.handle
run = eff.run
inst = eff.inst
perform = eff.perform

local free = eff.free
local Return = free.Return

local Yield = inst()
local yield = function(v)
  return perform(Yield, v)
end

local create = function(f)
  return { it = f, wrapped = false }
end

local resume = function(co, v)
  if co.wrapped then
    return co.it(v)
  else
    co.wrapped = true

    return handle({
      val = Return,
      [Yield] = function(u, k)
        co.it = k
        return Return(u)
      end
    }, co.it(v))
  end
end

return {
  resume = resume,
  yield = yield,
  create = create
}
