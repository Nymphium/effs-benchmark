local eff = require('eff/src/eff')
local inst, perform, handler = eff.inst, eff.perform, eff.handler

local imut = require('utils/imut')

local State = function()
  local Get = inst()
  local Put = inst()
  local History = inst()

  local get = function()
    return perform(Get)
  end
  local put = function(v)
    return perform(Put, v)
  end
  local history = function()
    return perform(History)
  end

  local run = function(f, init)
    -- local s = init
    -- local hist = {}

    -- return handler {
      -- val = function() return end,
      -- [Get] = function(k)
        -- return k(s)
      -- end,
      -- [Put] = function(k, ss)
        -- s = ss
        -- table.insert(hist, ss)
        -- return k()
      -- end,
      -- [History] = function(k)
        -- return k(imut.cp(hist))
      -- end
    -- }(f)

    local comp = handler({
      val = function() return function() end end,
      [Get] = function(_, k)
        return function(s, h)
          return k(s)(s, h)
        end
      end,
      [Put] = function(v, k)
        return function(_, h)
          return k()(v, imut.cons(v, h))
        end
      end,
      [History] = function(_, k)
        return function(s, h)
          return k(imut.rev(h))(s, imut.cp(h))
        end
      end
    })(f)

    return comp(init, {})
  end

  return {
    run = run,
    get = get,
    put = put,
    history = history
  }
end

local is = State()
local ss = State()

local main = function()
  print(is.get())
  is.put(42)
  print("OK")
  print(ss.get())
  ss.put("Hello")
  print(is.get())
  ss.put("world")
  print(is.get())
  is.put(21)
  is.get()

  print(ss.get())

  for _, v in ipairs(is.history()) do
    print(v)
  end

  for _, v in ipairs(ss.history()) do
    print(v)
  end
end

is.run(function() return ss.run(main, "") end, 0)
