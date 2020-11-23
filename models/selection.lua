local middleclass = require("middleclass")
local typeutils = require("typeutils")
local physics = require("physics")

local Selection = middleclass("Selection")

function Selection:initialize(primary_stone, secondary_stone)
  assert(primary_stone == nil or type(primary_stone) == "table")
  assert(secondary_stone == nil or type(secondary_stone) == "table")

  self.primary_stone = primary_stone
  self.secondary_stone = secondary_stone
end

function Selection:stones()
  return {self.primary_stone, self.secondary_stone}
end

function Selection:activate(world, x, y)
  assert(type(world) == "table")
  assert(typeutils.is_number_with_limits(x, 0))
  assert(typeutils.is_number_with_limits(y, 0))

  self:_set_kind("dynamic")

  if self.primary_stone then
    self.stone_joint = world:addJoint("MouseJoint", self.primary_stone, x, y)
  end
end

function Selection:update(x, y)
  assert(typeutils.is_number_with_limits(x, 0))
  assert(typeutils.is_number_with_limits(y, 0))

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
  assert(kind == "static" or kind == "dynamic")

  physics.process_colliders(self:stones(), function(stone)
    stone.body:setType(kind)
  end)
end

return Selection
