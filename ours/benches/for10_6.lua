local program = require('benches/for_hina')

local main = function()
  return program(10^6)
end

return {
  main = main
}
