local eff = require('eff.src.eff')
local inst, handler, perform
inst = eff.inst
handler = eff.handler
perform = eff.perform

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
  local t = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

  for i = 1, #t do
    perform(Write, perform(Double, t[i]))
  end
end

local main = function()
  return with_write()(function()
    return with_double(program)
  end)
end

return {
  main = main
}
