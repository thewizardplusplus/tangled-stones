---
-- @classmod StoneGroup

local middleclass = require("middleclass")
local mlib = require("mlib")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Rectangle = require("models.rectangle")
local Selection = require("models.selection")
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
-- @tparam Rectangle screen
-- @tparam number side_count [0, ∞)
-- @tparam number grid_step [0, screen.height]
-- @treturn {windfield.Collider,...} stones
-- @treturn {[windfield.Collider]=bool,...} stone index
function StoneGroup.static._make_stones(world, screen, side_count, grid_step)
  assertions.is_table(world)
  assertions.is_instance(screen, Rectangle)
  assertions.is_number(side_count)
  assertions.is_number(grid_step)

  local stones = {}
  local stone_index = {}
  local offset_x = screen.x + screen.width / 2 - side_count * grid_step / 2
  local offset_y = screen.y + screen.height / 2 - side_count * grid_step / 2
  for row = 0, side_count - 1 do
    for column = 0, side_count - 1 do
      local stone = physics.make_collider(world, "static", Rectangle:new(
        offset_x + column * grid_step,
        offset_y + row * grid_step,
        grid_step,
        grid_step
      ))
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

    local x1, y1 = prev_stone:getPosition()
    local x2, y2 = stone:getPosition()
    world:addJoint(
      "RopeJoint",
      prev_stone,
      stone,
      x1, y1,
      x2, y2,
      mlib.line.getLength(x1, y1, x2, y2),
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
-- @tparam Rectangle screen
-- @tparam number side_count [0, ∞)
-- @treturn StoneGroup
function StoneGroup:initialize(world, screen, side_count)
  assertions.is_table(world)
  assertions.is_instance(screen, Rectangle)
  assertions.is_number(side_count)

  self._grid_step = screen.height / (side_count + 4)
  self._stones, self._stone_index =
    StoneGroup._make_stones(world, screen, side_count, self._grid_step)
  table.shuffle(self._stones)

  self._stone_pairs = StoneGroup._make_joints(world, self._stones)
end

---
-- @treturn number [0, ∞)
function StoneGroup:stone_size()
  return self._grid_step
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
-- @tparam number x [0, ∞)
-- @tparam number y [0, ∞)
function StoneGroup:select_stones(world, x, y)
  assertions.is_table(world)
  assertions.is_number(x)
  assertions.is_number(y)

  local primary_stone = nil
  local minimal_distance = math.huge
  local colliders = world:queryCircleArea(x, y, 1.5 * self._grid_step / 2)
  for _, collider in ipairs(colliders) do
    if self._stone_index[collider] then
      local distance = mlib.line.getLength(x, y, collider:getPosition())
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
-- @tparam Rectangle screen
-- @tparam number side_count [0, ∞)
function StoneGroup:reset(world, screen, side_count)
  assertions.is_table(world)
  assertions.is_instance(screen, Rectangle)
  assertions.is_number(side_count)

  physics.process_colliders(self._stones, function(stone)
    assertions.is_table(stone)

    stone:destroy()
  end)

  self:initialize(world, screen, side_count)
end

return StoneGroup
