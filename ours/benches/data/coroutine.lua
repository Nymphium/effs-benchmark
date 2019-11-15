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
  return { it = f, wrapped = false }
end

local resume = function(co, v)
  if co.wrapped then
    return co.it(v)
  else
    co.wrapped = true

    return handler {
      val = function(x) return x end,
      [Yield] = function(u, k)
        co.it = k
        return u
      end
    }(function() return co.it(v) end)
  end
end

return {
  resume = resume,
  yield = yield,
  create = create
}
