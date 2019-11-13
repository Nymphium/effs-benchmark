local coroutine = require('ours/benches/data/coroutine')

local package_path = package.path
package.path = package.path .. ";../?.lua"
local Tree = require('utils.tree')
package.path = package_path

local Leaf = Tree.Leaf
local Node = Tree.Node

local function leaves(tree)
  if tree.cls == "Leaf" then
    return coroutine.yield(tree[1]) -- returns leaf value
  end

  leaves(tree[1])
  leaves(tree[2])
end

local leaves_co = function(t)
  return coroutine.create(function() return leaves(t) end)
end

local same_fringe = function(t1, t2)
  local c1 = leaves_co(t1)
  local c2 = leaves_co(t2)

  while true do
    local r1 = coroutine.resume(c1)
    local r2 = coroutine.resume(c2)

    if not (r1 and r2 and r1 == r2) then
      return not (r1 or r2)
    end
  end
end

do
  local t1 = Node(Leaf(1), Node(Leaf(2), Leaf(3)))
  local t2 = Node(Node(Leaf(1), Leaf(2)), Leaf((3)))
  local t3 = Node(Node(Leaf(3), Leaf(1)), Leaf((1)))
  local t7 = Node(Leaf(1), Node(Leaf(2), Leaf(3)))

  assert(same_fringe(t1, t2))
  assert(same_fringe(t2, t1))
  assert(not same_fringe(t1, t3))
  assert(same_fringe(t1, t7))
  assert(same_fringe(t2, t7))

  local tt1, tt2 = Tree.two_rand_tree(10)
  local tt3 = Tree.random_tree(10)
  assert(same_fringe(tt1, tt2))
  assert(same_fringe(tt2, tt1))
  assert(same_fringe(tt1, tt1))
  assert(not same_fringe(tt1, tt3))
  assert(not same_fringe(tt2, tt3))
end

local main = function(n)
  local tt1, tt2 = Tree.two_rand_tree(n)
  assert(same_fringe(tt1, tt2))
end

return main

