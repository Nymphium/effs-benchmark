local free = require('free')
local Return, Call, op
Return = free.Return
Call = free.Call
op = free.op

local eff = require('free_eff')
local handle, handler, run, inst, perform, perform_
handle = eff.handle
handler = eff.handler
run = eff.run
inst = eff.inst
perform = eff.perform
perform_ = eff.perform_


-----

local Exception = inst()
local raise = function(reason)
  return perform(Exception, reason)
end

local safediv = function(x, y)
  if (y == 0) then
    return raise("divide by zero")
  else
    return Return(x / y)
  end
end


local Maybe do
  local Just = function(v)
    return { type = "Just", v }
  end

  local Nothing = { type = "Nothing" }

  local match = function(e, t)
    return t[e.type](table.unpack(e))
  end

  local function with_exn(e)
    local r = handle(handler {
      val = Just,
      [Exception] = function(_, _)
        return Nothing
      end
    }, e)

    return Return(r)
  end

  Maybe = {
    Just = Just,
    Nothing = Nothing,
    match = match,
    with_exn = with_exn
  }
end

local IO do
  local GetLine = inst()

  local with_stdin = handler {
    val = Return,
    [GetLine] = function(_, k)
      return k(io.read())
    end
  }

  local with_testinput do
    local t = tonumber(tostring({}):match("0x[0-9]+")) % 4
    print("divider", t)

    local res = { 3, t }
    local idx = -1
    with_testinput = handler {
      val = Return,
      [GetLine] = function(_, k)
        idx = idx + 1
        return k(res[idx % #res + 1])
      end
    }
  end

  IO = {
    GetLine = GetLine,
    with_stdin = with_stdin,
    with_testinput = with_testinput
  }
end

local program1 = perform(IO.GetLine, nil) >> function(line)
  local x = tonumber(line)

  return perform(IO.GetLine, nil) >> function(line2)
    local y = tonumber(line2)
    return safediv(x, y)
  end
end

local res = run(
    Maybe.with_exn(
        handle(IO.with_stdin, program1)
    ))

Maybe.match(res, {
  Just = function(v)
    print("Just", v)
  end,
  Nothing = function()
    print("Nothing")
  end
})
