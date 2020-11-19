local middleclass = require("middleclass")

local Selection = middleclass("Selection")

function Selection:initialize(primary_stone, secondary_stone)
  self.primary_stone = primary_stone
  self.secondary_stone = secondary_stone
end

return Selection
