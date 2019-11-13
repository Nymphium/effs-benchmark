local eff = require('free_eff')
local effrun = eff.run
local free = eff.free
local Return, Call, op
Return = free.Return
Call = free.Call
op = free.op


local State = require('benches/state')

local s do
  s = {}

  for i = 1, 10 do
    s[i] = State()
  end
end

return function()
  local program = s[1].get() >> function(a)
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
           return Return(a + b + c + d + e + f + g + h + i)
     end end end end end end end end end end end end

  local p = program
  for i = 1, 10 do
    p = s[i].run(i, p)
  end

  return effrun(p)
end

