local State = require('ours/benches/data/state')

local SIZE = 10^5
local states do
  states = {}

  for _ = 1, SIZE do
    table.insert(states, State())
  end
end

local S = states[SIZE]
local get = S.get
local modify = S.modify
local runState = S.run

-----

local function count()
  local i = get()
  if i == 0 then return 0
  else
    modify(function(_) return i - 1 end)
    return count()
  end
end

local main = function(n)
  local p = count
  for i = 1, n - 1 do
    local pp = p -- avoid recursive definition
    p = function() return states[i].run(0, pp) end
  end

  return runState(10^3, p)
end

return main

