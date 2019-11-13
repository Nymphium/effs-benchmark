local eff = require('eff/src/eff')
local handler, inst, perform
handler = eff.handler
inst = eff.inst
perform = eff.perform

---

local State = function()
  local Eff = inst()
  local get = function()
    return perform(Eff, { type = "get" })
  end

  local modify = function(f)
    return perform(Eff, { type = "modify", f })
  end

  local run = function(init, th)
    local state = init

    local h = handler(Eff,
                      function(v) return v end,
                      function(r, k)
                        if r.type == "get" then
                          return k(state)
                        elseif r.type == "modify" then
                          local f = r[1]
                          state = f(state)
                          return k()
                        end
                      end)

    return h(th)
  end

  return {
    get = get,
    modify = modify,
    run = run
  }
end

return {
  main = function()
    local SIZE = 1000

    local s do
      s = {}

      for i = 1, SIZE do
        s[i] = State()
      end
    end

    local program = function()
      local a = s[1].get()
      local a = s[1].get()
      local a = s[1].get()
      local a = s[1].get()
      local a = s[1].get()
      local a = s[1].get()
      local a = s[1].get()
      local a = s[1].get()
      local a = s[1].get()
      local a = s[1].get()
      local a = s[1].get()
      local b = s[2].get()
      s[3].modify(function(c)
        return a + b + c
      end)
      local c = s[3].get()
      local d = s[4].get()
      local e = s[5].get()
      s[6].modify(function(f)
        return d + e + f
      end)
      local f = s[6].get()
      local g = s[7].get()
      local h = s[8].get()
      local i = s[9].get()
      local j = s[10].get()
      local j = s[10].get()
      local j = s[10].get()
      local j = s[10].get()
      local j = s[10].get()
      local j = s[10].get()
      local j = s[10].get()
      local j = s[10].get()
      local j = s[10].get()
      local j = s[10].get()

      return a + b + c + d + e + f + g + h + i
    end

    local p = program
    for i = 1, SIZE do
      local pp = p

      p = function()
        return s[i].run(i, pp)
      end
    end

    return p()
  end
}

