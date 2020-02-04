local handle_exn = function(th)
  local ok, ret = pcall(th)
  if not ok then
    if ret.tag == "Exception" then
      return ret.val
    end
  end

  return ret
end

return function(iter)
  for _ = 1, iter do
    handle_exn(function()
      return error({tag = "Exception", val = 1})
    end)
  end
end
