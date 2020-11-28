---
-- @classmod UiUpdate

local middleclass = require("middleclass")

---
-- @table instance
-- @tfield bool reset

local UiUpdate = middleclass("UiUpdate")

---
-- @function new
-- @tparam bool reset
-- @treturn UiUpdate
function UiUpdate:initialize(reset)
  assert(type(reset) == "boolean")

  self.reset = reset
end

return UiUpdate
