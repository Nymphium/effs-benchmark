local eff = require('free/free_eff')
local free = eff.free
local bind = free.op.bind
local Return = free.Return

local State = require('free/benches/data/state')
  -- 充分な数のstateを作る
local SIZE = 10^5
local states do
  states = {}

  for _ = 1, SIZE do
    table.insert(states, State())
  end
end

local S = states[SIZE]
local runState = S.run
local get = S.get
local modify = S.modify

-----

local function count()
  return bind(get(), function(i)
    if i == 0 then
      return Return(i)
    else
      return bind(modify(function(_) return i - 1 end), function()
        return count()
      end)
    end
  end)
end

local main = function(n)
  local p = count()

  for i = 1, n - 1 do
    local pp = p
    p = states[i].run(0, pp)
  end

  return runState(10^3, p)
end

return main

