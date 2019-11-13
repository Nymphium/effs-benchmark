local eff = require('ours/eff/src/eff')
local handler, inst, perform
handler = eff.handler
inst = eff.inst
perform = eff.perform

---

local Log = inst()
local log = function(msg)
  return perform(Log, msg)
end

local collect_log_handler = function()
  local msgs = {}

  return handler {
    val = function(v)
      return {v, msgs}
    end,
    [Log] = function(msg, k)
      table.insert(msgs, msg)
      return k()
    end
  }
end

local program = function(iter)
  local r = collect_log_handler()(function()
    for i = 1, iter do
      log(i)
    end
  end)

  assert(#(r[2]) == iter)
end

return program

