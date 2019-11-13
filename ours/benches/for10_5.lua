local program = require('benches/for_hina')

local main = function()
  return program(10^5)
end

return {
  main = main
}

