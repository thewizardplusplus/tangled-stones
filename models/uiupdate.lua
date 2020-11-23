local middleclass = require("middleclass")

local UiUpdate = middleclass("UiUpdate")

function UiUpdate:initialize(reset)
  assert(type(reset) == "boolean")

  self.reset = reset
end

return UiUpdate
