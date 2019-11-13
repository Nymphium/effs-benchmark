local eff = require('eff/src/eff')
local handler, inst, perform
handler = eff.handler
inst = eff.inst
perform = eff.perform

---

local package_path = package.path
package.path = package.path .. ";../?.lua"
-- local imut = require('utils.imut')
-- local ref  = require('utils.ref')
package.path = package_path

local id = function(v)
  return v
end

-- local handlePure = handler { val = id }

local Get = inst()
local get = function()
  return perform(Get)
end

local Put = inst()
local put = function(v)
  return perform(Put, v)
end

-- local monadicState = handler {
  -- val = function(v)
    -- return function(s)
      -- return {v, s}
    -- end
  -- end,
  -- [Put] = function(s, k)
    -- return function()
      -- return k()(s)
    -- end
  -- end,
  -- [Get] = function(_, k)
    -- return function(s)
      -- return k(s)(s)
    -- end
  -- end
-- }

local simpleState = handler {
  val = function(x)
    return function()
      return x
    end
  end,
  [Put] = function(s, k)
    return function()
      return k()(s)
    end
  end,
  [Get] = function(_, k)
    return function(s)
      return k(s)(s)
    end
  end
}

-- local logState = handler {
  -- val = function(x)
    -- return function(ss)
      -- -- tail . reverse ss
      -- return {x, imut.tail(imut.rev(ss))}
    -- end
  -- end,
  -- [Get] = function(_, k)
    -- return function(sss)
      -- return k(sss[1])(sss)
    -- end
  -- end,
  -- [Put] = function(s, k)
    -- return function(ss)
      -- return k()(imut.cons(s, ss))
    -- end
  -- end
-- }

-- local ioRefState = handler {
  -- val = function(x)
    -- return function()
      -- return x
    -- end
  -- end,
  -- [Get] = function(_, k)
    -- return function(r)
      -- return k(~r)(r)
    -- end
  -- end,
  -- [Put] = function(s, k)
    -- return function(r)
      -- r(s)
      -- k()(r)
    -- end
  -- end
-- }

---

local Err = inst()
local err = function(m)
  return perform(Err, m)
end

local WrapT = "wrap"
local Wrap = function(th)
  return {
    type = WrapT,
    unWrap = function()
      return th()
    end
  }
end

local forwardState = handler {
  val = function(x)
    return function()
      return Wrap(function() return x end)
    end
  end,
  [Put] = function(s, k)
    return function()
      return k()(s)
    end
  end,
  [Get] = function(_, k)
    return function(s)
      return k(s)(s)
    end
  end,
  [Err] = function(m, k)
    return function(s)
      return Wrap(function()
        local x = err(m)
        return k(x)(s).unwrap()
      end)
    end
  end
}

---

-- local LogPut = inst()
-- local logPut = function(m)
  -- return perform(LogPut, m)
-- end

-- local putLogger = handler {
  -- val = id,
  -- [Put] = function(s, k)
    -- logPut(s)
    -- put(s)
    -- return k()
  -- end
-- }

-- local logPutReturner = handler {
  -- val = function(x)
    -- return {x, {}}
  -- end,
  -- [LogPut] = function(s, k)
    -- local t = k()
    -- -- t = {x, ss}
    -- return {t[1], imut.cons(s, t[2])}
  -- end
-- }

-- local logPutPrinter = handler {
  -- val = id,
  -- [LogPut] = function(s, k)
    -- print("Put", s)
    -- return k()
  -- end
-- }

local PrintLine = inst()

local printHandler = handler {
  val = id,
  [PrintLine] = function(s, k)
    print(s)
    return k()
  end
}

-- local stateWithLog = function(s, comp)
  -- return handlePure(function()
    -- return logPutPrinter(function()
      -- return forwardState(function()
        -- return putLogger(comp)
      -- end)(s)
    -- end)
  -- end)
-- end

-- local stateWithLog = function(s, comp)
  -- return printHandler(function()
    -- return logPutPrinter(function()
      -- return forwardState(function()
        -- return putLogger(comp)
      -- end)(s)
    -- end)
  -- end)
-- end

-- local RightT = "right"
-- local Right = function(v)
  -- return { type = RightT, v = v }
-- end

-- local LeftT = "left"
-- local Left = function(v)
  -- return { type = LeftT, v = v }
-- end

-- local reportErr = handler {
  -- val = Right,
  -- [Err] = function(v, _)
    -- return Left(v)
  -- end
-- }

-- local stateErr = function(s, th)
  -- return reportErr(function()
    -- return forwardState(th)(s)
  -- end)
-- end

-- local comp2 = function()
  -- local x = get()
  -- if x == 0 then
    -- return err"division by zero"
  -- else
    -- put(256 / x)
    -- local y = get()
    -- return y + 16
  -- end
-- end

-- local comp0 = function()
  -- local x = get()
  -- put("zig-" .. x)
  -- local y = get()
  -- put(y .. ":" .. y)
  -- return get()
-- end

-- local testa = function()
    -- return monadicState(comp0)("zag")
-- end

-- local testb = function()
  -- return simpleState(comp0)("zag")
-- end

-- local testc = function()
  -- return logState(comp0)({"zag"})
-- end

-- local testd = function()
  -- local r = ref("zag")
  -- ioRefState(comp0)(r)
-- end

-- local comp1 = function()
  -- local x = get()
  -- put(x + 1)
  -- local y = get()
  -- put(y + y)
  -- return get()
-- end

-- local test1 = function()
  -- return monadicState(comp1)(1)
-- end

-- local test2 = function()
  -- return simpleState(comp1)(1)
-- end

-- local test3 = function()
  -- return logState(comp1){1}
-- end

-- local test3 = function()
  -- local r = ref(1)
  -- return ioRefState(comp1)(r)
-- end

local function count()
  local i = get()
  if i == 0 then return 1
  else
    put(i - 1)
    return count()
  end
end

local simple = simpleState(count)

local forward = function(n)
  return printHandler(function()
    return forwardState(count)(n)
  end)
end

local iterations = 10^5

local main = function()
  simple(iterations)
  forward(iterations)
end

return { main = main }
