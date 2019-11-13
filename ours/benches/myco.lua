local eff = require('eff/src/eff')
local handler, inst, perform
handler = eff.handler
inst = eff.inst
perform = eff.perform

---

local myco do
  myco = {}

  local yield = inst()

  myco.yield = function(v)
    return perform(yield, v)
  end

  myco.create = function(f)
    return { it = f }
  end

  myco.resume = function(co, v)
    return handler {
      val = function(x) return x end,
      [yield] = function(u, k)
        co.it = k
        return u
      end
    }(function() return co.it(v) end)
  end
end

local Leaf = function(a)
  return {a, cls = "Leaf"}
end

local Node = function(l, r)
  return {l, r, cls = "Node"}
end

local function leaves(tree)
  if tree.cls == "Leaf" then
    return myco.yield(tree[1]) -- returns leaf value
  end

  leaves(tree[1])
  leaves(tree[2])
end

local leaves_co = function(t)
  return myco.create(function() return leaves(t) end)
end

local same_fringe = function(t1, t2)
  local c1 = leaves_co(t1)
  local c2 = leaves_co(t2)

  while true do
    local r1 = myco.resume(c1)
    local r2 = myco.resume(c2)

    if not (r1 and r2 and r1 == r2) then
      return not (r1 or r2)
    end
  end
end

local t1 = Node(Leaf(1), Node(Leaf(2), Leaf(3)))
local t2 = Node(Node(Leaf(1), Leaf(2)), Leaf((3)))
local t3 = Node(Node(Leaf(3), Leaf(1)), Leaf((1)))
local t7 = Node(Leaf(1), Node(Leaf(2), Leaf(3)))

assert(same_fringe(t1, t2))
assert(same_fringe(t2, t1))
assert(not same_fringe(t1, t3))
assert(same_fringe(t1, t7))
assert(same_fringe(t2, t7))

