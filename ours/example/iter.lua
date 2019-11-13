local eff = require('eff/src/eff')

local Yield = eff.inst()

-- ('e -> bool) -> ('e iterable) -> ('e -> unit) -> unit
local iterate = function(p, obj, f)
  local h = handler {
    val = function(_) return end,
    [Yield] = function(e, k)
      if p(e) then
        f(e)
        return k()
      end
    end
  }

  return h(function()
    
  end)
end

iterate(function(a) return a ~= nil end, { 1, 2, 3 }, function(e)
  print(e)
end)

