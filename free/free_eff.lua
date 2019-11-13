local free = require('free/free')
local Return, Call
Return = free.Return
Call = free.Call

local function handle(h, v)
  if v.type == "Return" then
    return h.val(v.x)
  elseif v.type == "Call" then
    local k = function(y)
      return handle(h, v.k(y))
    end

    local effh = h[v.op]
    if effh then
      return effh(v.x, k)
    else
      return Call(v.op, v.x, k)
    end
  end
end

local run = function(v --[[assume Return]])
  return v.x
end

-- instanciate effect
-- Note:
--   `{} == {}` returns always `false`.
--   `local t = {}; t == t` returns `true`.
local inst = function()
  return {}
end

local perform = function(op, x)
  return Call(op, x, Return)
end

-- flipped version
local perform_ = function(op, k)
  return function(x)
    return Call(op, x, k)
  end
end

return {
  free = free,
  handle = handle,
  run = run,
  inst = inst,
  perform = perform,
  perform_ = perform_
}
