---
-- @classmod UiUpdate

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")

---
-- @table instance
-- @tfield bool reset

local UiUpdate = middleclass("UiUpdate")

---
-- @function new
-- @tparam bool reset
-- @treturn UiUpdate
function UiUpdate:initialize(reset)
  assertions.is_boolean(reset)

  self.reset = reset
end

return UiUpdate
