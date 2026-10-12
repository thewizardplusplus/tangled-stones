---
-- @classmod StoneGroup

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Vector2D = require("luamath.vector2d")
local Matrix3x3 = require("luamath.matrix3x3")
local Size = require("luamath.models.size")
local BoundingBox = require("luamath.models.boundingbox")
local Selection = require("models.selection")
local BorderGroup = require("groups.bordergroup")
local physics = require("physics")

---
-- @table instance
-- @tfield number _grid_step
-- @tfield {windfield.Collider,...} _stones
-- @tfield {[windfield.Collider]=bool,...} _stone_index
-- @tfield {[windfield.Collider]=windfield.Collider,...} _stone_pairs

local StoneGroup = middleclass("StoneGroup")

---
-- @function _make_stones
-- @static
-- @tparam windfield.World world
-- @tparam BoundingBox screen
-- @tparam number side_count [0, ∞)
-- @tparam number grid_step [0, screen.height]
-- @treturn {windfield.Collider,...} stones
-- @treturn {[windfield.Collider]=bool,...} stone index
function StoneGroup.static._make_stones(world, screen, side_count, grid_step)
  assertions.is_table(world)
  assertions.is_instance(screen, BoundingBox)
  assertions.is_number(side_count)
  assertions.is_number(grid_step)

  local stones = {}
  local stone_index = {}
  local stone_size = Size:new(grid_step, grid_step)
  local stone_group_size = stone_size * side_count
  local stone_group_transform =
    Matrix3x3.translate(screen:center() - stone_group_size / 2)
    * Matrix3x3.scale(grid_step)
  for row = 0, side_count - 1 do
    for column = 0, side_count - 1 do
      local position = Vector2D:new(column, row) * stone_group_transform
      local bounding_box =
        BoundingBox.from_position_and_size(position, stone_size)
      local stone = physics.make_collider(world, "static", bounding_box)
      table.insert(stones, stone)
      stone_index[stone] = true
    end
  end

  return stones, stone_index
end

---
-- @function _make_joints
-- @static
-- @tparam windfield.World world
-- @tparam {windfield.Collider,...} stones
-- @treturn {[windfield.Collider]=windfield.Collider,...} stone pairs
function StoneGroup.static._make_joints(world, stones)
  assertions.is_table(world)
  assertions.is_sequence(stones, checks.is_table)

  local stone_pairs = {}
  local prev_stone = nil
  physics.process_colliders(stones, function(stone)
    assertions.is_table(stone)

    if not prev_stone then
      prev_stone = stone
      return
    end

    local start = Vector2D:new(prev_stone:getPosition())
    local finish = Vector2D:new(stone:getPosition())
    world:addJoint(
      "RopeJoint",
      prev_stone,
      stone,
      start.x, start.y,
      finish.x, finish.y,
      (finish - start):length(),
      true
    )

    stone_pairs[prev_stone] = stone
    stone_pairs[stone] = prev_stone

    prev_stone = nil
  end)

  return stone_pairs
end

---
-- @function new
-- @tparam windfield.World world
-- @tparam BoundingBox screen
-- @tparam number side_count [0, ∞)
-- @treturn StoneGroup
function StoneGroup:initialize(world, screen, side_count)
  assertions.is_table(world)
  assertions.is_instance(screen, BoundingBox)
  assertions.is_number(side_count)

  local border_size = BorderGroup.border_size(screen)
  self._grid_step =
    (screen:y_range():length() - 2 * border_size) / (side_count + 3)
  self._stones, self._stone_index =
    StoneGroup._make_stones(world, screen, side_count, self._grid_step)
  table.shuffle(self._stones)

  self._stone_pairs = StoneGroup._make_joints(world, self._stones)
end

---
-- @treturn Size
function StoneGroup:stone_size()
  return Size:new(self._grid_step, self._grid_step)
end

---
-- @treturn number [0, ∞)
function StoneGroup:count()
  local count = 0
  physics.process_colliders(self._stones, function()
    count = count + 1
  end)

  return count
end

---
-- @tparam windfield.World world
-- @tparam Vector2D position
function StoneGroup:select_stones(world, position)
  assertions.is_table(world)
  assertions.is_instance(position, Vector2D)

  local primary_stone = nil
  local minimal_distance = math.huge
  local colliders = world:queryCircleArea(
    position.x,
    position.y,
    1.5 * self._grid_step / 2
  )
  for _, collider in ipairs(colliders) do
    if self._stone_index[collider] then
      local collider_position = Vector2D:new(collider:getPosition())
      local distance = (collider_position - position):length()
      if distance < minimal_distance then
        primary_stone = collider
        minimal_distance = distance
      end
    end
  end

  local secondary_stone = nil
  if primary_stone then
    secondary_stone = self._stone_pairs[primary_stone]
  end

  return Selection:new(primary_stone, secondary_stone)
end

---
-- @tparam windfield.World world
-- @tparam BoundingBox screen
-- @tparam number side_count [0, ∞)
function StoneGroup:reset(world, screen, side_count)
  assertions.is_table(world)
  assertions.is_instance(screen, BoundingBox)
  assertions.is_number(side_count)

  physics.process_colliders(self._stones, function(stone)
    assertions.is_table(stone)

    stone:destroy()
  end)

  self:initialize(world, screen, side_count)
end

return StoneGroup
