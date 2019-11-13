local S = require('benches/state')()
local get = S.get
local modify = S.modify
local runState = S.run

local function count()
  local i = get()
  if i == 0 then return 0
  else
    modify(function(_) return i - 1 end)
    return count()
  end
end

local main = function(n)
  return runState(n, count)
end

return main
