local middleclass = require("middleclass")
local typeutils = require("typeutils")

local Stats = middleclass("Stats")

function Stats:initialize(current, minimal)
  assert(typeutils.is_number_with_limits(current, 0))
  assert(typeutils.is_number_with_limits(minimal, 0))

  self.current = current
  self.minimal = minimal
end

return Stats
