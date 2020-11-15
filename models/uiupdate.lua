local middleclass = require("middleclass")

local UiUpdate = middleclass("UiUpdate")

function UiUpdate:initialize(reset)
  self.reset = reset
end

return UiUpdate
