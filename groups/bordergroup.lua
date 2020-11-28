---
-- @classmod BorderGroup

local middleclass = require("middleclass")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")
local physics = require("physics")

---
-- @table instance
-- @tfield number _bottom_limit
-- @tfield {windfield.Collider,...} _borders

local BorderGroup = middleclass("BorderGroup")

---
-- @function new
-- @tparam windfield.World world
-- @tparam Rectangle screen
-- @tparam number stone_size [0, screen.height]
-- @treturn BorderGroup
function BorderGroup:initialize(world, screen, stone_size)
  assert(type(world) == "table")
  assert(typeutils.is_instance(screen, Rectangle))
  assert(typeutils.is_positive_number(stone_size, screen.height))

  local grid_step = screen.height / 20
  self._bottom_limit = screen.y + screen.height - grid_step - stone_size / 4

  local top = physics.make_collider(world, "static", Rectangle:new(
    screen.x + grid_step,
    screen.y,
    screen.width - 2 * grid_step,
    grid_step
  ))
  local bottom_left = physics.make_collider(world, "static", Rectangle:new(
    screen.x + grid_step,
    screen.y + screen.height - grid_step,
    (screen.width - 2 * grid_step - 1.5 * stone_size) / 2,
    grid_step
  ))
  local bottom_right = physics.make_collider(world, "static", Rectangle:new(
    screen.x + (screen.width + 1.5 * stone_size) / 2,
    screen.y + screen.height - grid_step,
    (screen.width - 2 * grid_step - 1.5 * stone_size) / 2,
    grid_step
  ))
  local left = physics.make_collider(world, "static", Rectangle:new(
    screen.x,
    screen.y,
    grid_step,
    screen.height
  ))
  local right = physics.make_collider(world, "static", Rectangle:new(
    screen.x + screen.width - grid_step,
    screen.y,
    grid_step,
    screen.height
  ))
  self._borders = {top, bottom_left, bottom_right, left, right}
end

---
-- @tparam windfield.Collider stone
-- @treturn bool
function BorderGroup:is_out(stone)
  assert(type(stone) == "table")

  local _, y = stone:getPosition()
  return y > self._bottom_limit
end

---
-- @tparam windfield.World world
-- @tparam Rectangle screen
-- @tparam number stone_size [0, screen.height]
function BorderGroup:reset(world, screen, stone_size)
  assert(type(world) == "table")
  assert(typeutils.is_instance(screen, Rectangle))
  assert(typeutils.is_positive_number(stone_size, screen.height))

  physics.process_colliders(self._borders, function(border)
    border:destroy()
  end)

  self:initialize(world, screen, stone_size)
end

return BorderGroup
