-- allocate variable for back patching
local bind
local then_

-- type computation =
local computation = function(t, a)
  return setmetatable(a, {
    __index = { type = t },
    __shr --[[ l >> r ]] = bind,
    __concat --[[ l .. r  ]] = then_,
  })
end

--   | Return of v
local Return = function(v)
  return computation("Return" , { x = v })
end

--   | Call of op * x * k
local Call = function(op, x, k)
  return computation("Call", { op = op, x = x, k = k })
end

------

-- v >>= f
bind = function(v, f)
  if v.type == "Return" then
    return f(v.x)
  elseif v.type == "Call" then
    return Call(v.op, v.x, function(y)
      return bind(v.k(y), f)
    end)
  end
end

then_ = function(l, r)
  if l.type == "Return" then
    return r
  else
    return bind(l, function()
      return r
    end)
  end
end

local for_ = function(t, proc)
  local function step(idx)
    if not t[idx] then
      return Return()
    else
      return proc(t[idx]) .. step(idx + 1)
    end
  end

  return step(1)
end

local seq = function(lma)
  return for_(lma, function(e) return e end)
end

return {
  Return = Return,
  Call = Call,
  op = {
    bind = bind,
    then_ = then_,
    for_ = for_,
  }
}
