local eff = require('eff/src/eff')
local handler, inst, perform
handler = eff.handler
inst = eff.inst
perform = eff.perform

---

local Double = inst()
local Write = inst()

local with_double = handler {
  val = function(v) return v end,
  [Double] = function(x, k)
    return k(x * x)
  end
}

local with_write = function()
  local t = {}

  return handler{
    val = function()
      for _, v in ipairs(t) do
        -- print(v)
      end
    end,
    [Write] = function(v, k)
      table.insert(t, v)
      return k()
    end
  }
end

local program = function()
  for i = 1, 10^7 do
    perform(Write, i)
  end
end

local main = function()
  return with_write()(program)
end

return {
  main = main
}
