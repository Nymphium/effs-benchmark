local eff = require('free/free_eff')
local free = eff.free
local bind = free.op.bind
local Return = free.Return

local S = require('free/benches/data/state')()
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
  return runState(n, count())
end

return main

