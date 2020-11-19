local middleclass = require("middleclass")
local physics = require("physics")

local Selection = middleclass("Selection")

function Selection:initialize(primary_stone, secondary_stone)
  self.primary_stone = primary_stone
  self.secondary_stone = secondary_stone
end

function Selection:activate(world, x, y)
  self:_set_kind("dynamic")

  if self.primary_stone then
    self.stone_joint = world:addJoint("MouseJoint", self.primary_stone, x, y)
  end
end

function Selection:update(x, y)
  if self.stone_joint then
    self.stone_joint:setTarget(x, y)
  end
end

function Selection:deactivate()
  self:_set_kind("static")

  if self.stone_joint then
    self.stone_joint:destroy()
    self.stone_joint = nil
  end
end

function Selection:_set_kind(kind)
  local stones = {self.primary_stone, self.secondary_stone}
  physics.process_colliders(stones, function(stone)
    stone.body:setType(kind)
  end)
end

return Selection
