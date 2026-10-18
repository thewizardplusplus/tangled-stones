---
-- @classmod BorderGroup

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Vector2D = require("luamath.vector2d")
local Size = require("luamath.models.size")
local Range = require("luamath.models.range")
local BoundingBox = require("luamath.models.boundingbox")
local physics = require("physics")

local BorderGroup = middleclass("BorderGroup")

---
-- @function border_size
-- @static
-- @tparam BoundingBox screen
-- @treturn int
function BorderGroup.static.border_size(screen)
  assertions.is_instance(screen, BoundingBox)

  return math.floor(screen:y_range():length() / 20)
end

---
-- @function _make_border
-- @static
-- @tparam windfield.World world
-- @tparam BoundingBox screen
-- @tparam Vector2D position relative to the screen
-- @tparam Size size
-- @treturn windfield.Collider
function BorderGroup.static._make_border(world, screen, position, size)
  assertions.is_table(world)
  assertions.is_instance(screen, BoundingBox)
  assertions.is_instance(position, Vector2D)
  assertions.is_instance(size, Size)

  local bounding_box =
    BoundingBox.from_position_and_size(screen:position() + position, size)
  return physics.make_collider(world, "static", bounding_box)
end

---
-- @table instance
-- @tfield Range _vertical_range
-- @tfield {windfield.Collider,...} _borders

---
-- @function new
-- @tparam windfield.World world
-- @tparam BoundingBox screen
-- @tparam Size stone_size
-- @treturn BorderGroup
function BorderGroup:initialize(world, screen, stone_size)
  assertions.is_table(world)
  assertions.is_instance(screen, BoundingBox)
  assertions.is_instance(stone_size, Size)

  local grid_step = BorderGroup.border_size(screen)
  self._vertical_range = Range:new(
    screen:y_range().min,
    screen:y_range().max - grid_step - stone_size.height / 4
  )

  local screen_size = screen:size()
  local horizontal_border_size =
    Size:new(screen_size.width - 2 * grid_step, grid_step)
  local bottom_horizontal_border_size =
    Size:new(
      (horizontal_border_size.width - 1.5 * stone_size.width) / 2,
      horizontal_border_size.height
    )
  local vertical_border_size = Size:new(grid_step, screen_size.height)

  local top = BorderGroup._make_border(
    world,
    screen,
    Vector2D:new(grid_step, 0),
    horizontal_border_size
  )
  local bottom_left = BorderGroup._make_border(
    world,
    screen,
    Vector2D:new(grid_step, screen_size.height - grid_step),
    bottom_horizontal_border_size
  )
  local bottom_right = BorderGroup._make_border(
    world,
    screen,
    Vector2D:new(
      (screen_size.width + 1.5 * stone_size.width) / 2,
      screen_size.height - grid_step
    ),
    bottom_horizontal_border_size
  )
  local left = BorderGroup._make_border(
    world,
    screen,
    Vector2D.ZERO,
    vertical_border_size
  )
  local right = BorderGroup._make_border(
    world,
    screen,
    Vector2D:new(screen_size.width - grid_step, 0),
    vertical_border_size
  )
  self._borders = {top, bottom_left, bottom_right, left, right}
end

---
-- @tparam windfield.Collider stone
-- @treturn bool
function BorderGroup:is_out(stone)
  assertions.is_table(stone)

  local _, y = stone:getPosition()
  return y > self._vertical_range.max
end

---
-- @tparam windfield.World world
-- @tparam BoundingBox screen
-- @tparam Size stone_size
function BorderGroup:reset(world, screen, stone_size)
  assertions.is_table(world)
  assertions.is_instance(screen, BoundingBox)
  assertions.is_instance(stone_size, Size)

  physics.process_colliders(self._borders, function(border)
    assertions.is_table(border)

    border:destroy()
  end)

  self:initialize(world, screen, stone_size)
end

return BorderGroup
