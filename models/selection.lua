---
-- @classmod Selection

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Vector2D = require("luamath.vector2d")
local physics = require("physics")

local Selection = middleclass("Selection")

---
-- @table instance
-- @tfield windfield.Collider primary_stone
-- @tfield windfield.Collider secondary_stone
-- @tfield Joint _stone_joint

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
  self._stone_joint = nil
end

---
-- @treturn {windfield.Collider,windfield.Collider} primary and secondary stones
function Selection:stones()
  return {self.primary_stone, self.secondary_stone}
end

---
-- @treturn bool
function Selection:is_activated()
  return self._stone_joint ~= nil
end

---
-- @tparam windfield.World world
-- @tparam Vector2D position
function Selection:activate(world, position)
  assertions.is_table(world)
  assertions.is_instance(position, Vector2D)

  self:_set_kind("dynamic")

  if self.primary_stone then
    self._stone_joint = world:addJoint(
      "MouseJoint",
      self.primary_stone,
      position.x,
      position.y
    )
  end
end

---
-- @tparam Vector2D position
function Selection:update(position)
  assertions.is_instance(position, Vector2D)

  if self._stone_joint then
    self._stone_joint:setTarget(position.x, position.y)
  end
end

---
-- @function deactivate
function Selection:deactivate()
  self:_set_kind("static")

  if self._stone_joint then
    self._stone_joint:destroy()
    self._stone_joint = nil
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
