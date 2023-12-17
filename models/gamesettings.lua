---
-- @classmod GameSettings

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")

---
-- @table instance
-- @tfield number side_count

local GameSettings = middleclass("GameSettings")

---
-- @function new
-- @tparam number side_count [0, ∞)
-- @treturn GameSettings
function GameSettings:initialize(side_count)
  assertions.is_number(side_count)

  self.side_count = side_count
end

return GameSettings
