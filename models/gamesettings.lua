---
-- @classmod GameSettings

local middleclass = require("middleclass")
local typeutils = require("typeutils")

---
-- @table instance
-- @tfield number side_count

local GameSettings = middleclass("GameSettings")

---
-- @function new
-- @tparam number side_count [0, ∞)
-- @treturn GameSettings
function GameSettings:initialize(side_count)
  assert(typeutils.is_positive_number(side_count))

  self.side_count = side_count
end

return GameSettings
