local eff = require('ours/eff/src/eff')
local handler, inst, perform
handler = eff.handler
inst = eff.inst
perform = eff.perform

---

local Yield = inst()

local yield = function(v)
  return perform(Yield, v)
end

local create = function(f)
  return { it = f }
end

local resume = function(co, v)
  return handler {
    val = function(x) return x end,
    [Yield] = function(u, k)
      co.it = k
      return u
    end
  }(function() return co.it(v) end)
end

return {
  resume = resume,
  yield = yield,
  create = create
}
