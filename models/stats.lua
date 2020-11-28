---
-- @classmod Stats

local middleclass = require("middleclass")
local typeutils = require("typeutils")

---
-- @table instance
-- @tfield number current [0, ∞)
-- @tfield number minimal [0, ∞)

local Stats = middleclass("Stats")

---
-- @function new
-- @tparam number current [0, ∞)
-- @tparam number minimal [0, ∞)
-- @treturn Stats
function Stats:initialize(current, minimal)
  assert(typeutils.is_positive_number(current))
  assert(typeutils.is_positive_number(minimal))

  self.current = current
  self.minimal = minimal
end

return Stats
