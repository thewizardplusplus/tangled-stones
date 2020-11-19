local middleclass = require("middleclass")
local physics = require("physics")

local Selection = middleclass("Selection")

function Selection:initialize(primary_stone, secondary_stone)
  self.primary_stone = primary_stone
  self.secondary_stone = secondary_stone
end

function Selection:set_kind(kind)
  local stones = {self.primary_stone, self.secondary_stone}
  physics.process_colliders(stones, function(stone)
    stone.body:setType(kind)
  end)
end

return Selection
