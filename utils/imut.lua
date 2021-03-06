local move = table.move
or function(src, from, to, on, dst)
  for  i = from, to do
    dst[i + on - 1] = src[i]
  end

  return dst
end

local cp = function(t)
  return move(t, 1, #t, 1, {})
end

local cons = function(e, t)
  local ret = cp(t)
  table.insert(ret, e)
  return ret
end

local rev = function(t)
  local ret = {}

  for i = #t, 1, -1 do
    table.insert(ret, t[i])
  end

  return ret
end

local tail = function(t)
  return move(t, 1, #t - 1, 1, {})
end

return {
  cp = cp,
  cons = cons,
  rev = rev,
  tail = tail
}

