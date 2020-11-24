local middleclass = require("middleclass")
local typeutils = require("typeutils")

local Stats = middleclass("Stats")

function Stats:initialize(current, minimal)
  assert(typeutils.is_positive_number(current))
  assert(typeutils.is_positive_number(minimal))

  self.current = current
  self.minimal = minimal
end

return Stats
