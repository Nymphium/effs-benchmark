local Leaf = function(a)
  return {a, cls = "Leaf"}
end

local Node = function(l, r)
  return {l, r, cls = "Node"}
end

local function random_tree(nodes)
  local r = math.random(100)

  if nodes == 1 then
    return Leaf(r)
  end

  local nodes_ = math.floor(nodes / 2)
  local nodes__ = nodes_ + (nodes % 2)

  if nodes_ == 0 then
    return Leaf(r)
  end

  return Node(random_tree(nodes_), random_tree(nodes__))
end

local R = 10^10
local I = 10^5

local two_rand_tree = function(nodes)
  local i = math.random(1, I)
  math.randomseed(i)
  local t1 = random_tree(nodes)
  math.randomseed(i)
  local t2 = random_tree(nodes)
  math.randomseed(math.random(1, R))

  return t1, t2
end

return {
  Leaf = Leaf,
  Node = Node,
  random_tree = random_tree,
  two_rand_tree = two_rand_tree
}
