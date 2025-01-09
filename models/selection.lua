---
-- @classmod Selection

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local physics = require("physics")

---
-- @table instance
-- @tfield windfield.Collider primary_stone
-- @tfield windfield.Collider secondary_stone

local Selection = middleclass("Selection")

---
-- @function new
-- @tparam windfield.Collider primary_stone
-- @tparam windfield.Collider secondary_stone
-- @treturn Selection
function Selection:initialize(primary_stone, secondary_stone)
  assertions.is_table_or_nil(primary_stone)
  assertions.is_table_or_nil(secondary_stone)

  self.primary_stone = primary_stone
  self.secondary_stone = secondary_stone
end

---
-- @treturn {windfield.Collider,windfield.Collider} primary and secondary stones
function Selection:stones()
  return {self.primary_stone, self.secondary_stone}
end

---
-- @treturn bool
function Selection:is_activated()
  return self.stone_joint ~= nil
end

---
-- @tparam windfield.World world
-- @tparam number x [0, ∞)
-- @tparam number y [0, ∞)
function Selection:activate(world, x, y)
  assertions.is_table(world)
  assertions.is_number(x)
  assertions.is_number(y)

  self:_set_kind("dynamic")

  if self.primary_stone then
    self.stone_joint = world:addJoint("MouseJoint", self.primary_stone, x, y)
  end
end

---
-- @tparam number x [0, ∞)
-- @tparam number y [0, ∞)
function Selection:update(x, y)
  assertions.is_number(x)
  assertions.is_number(y)

  if self.stone_joint then
    self.stone_joint:setTarget(x, y)
  end
end

---
-- @function deactivate
function Selection:deactivate()
  self:_set_kind("static")

  if self.stone_joint then
    self.stone_joint:destroy()
    self.stone_joint = nil
  end
end

---
-- @tparam "static"|"dynamic" kind
function Selection:_set_kind(kind)
  assertions.is_enumeration(kind, {"static", "dynamic"})

  physics.process_colliders(self:stones(), function(stone)
    assertions.is_table(stone)

    stone.body:setType(kind)
  end)
end

return Selection
