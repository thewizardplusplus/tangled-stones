local middleclass = require("middleclass")
local mlib = require("mlib")
local Rectangle = require("models.rectangle")
local physics = require("physics")

local function _make_stones(world, screen, side_count)
  local stones = {}
  local stone_index = {}
  local grid_step = screen.height / 10
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

local function _shuffle_array(array)
  -- Fisher-Yates shuffle
  for i = 1, #array do
    local j = math.random(i, #array)
    array[i], array[j] = array[j], array[i]
  end
end

local function _make_joints(world, stones)
  local stone_pairs = {}
  local prev_stone = nil
  physics.process_colliders(stones, function(stone)
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

local StoneGroup = middleclass("StoneGroup")

function StoneGroup:initialize(world, screen, side_count)
  self._stones, self._stone_index = _make_stones(world, screen, side_count)
  _shuffle_array(self._stones)

  self._stone_pairs = _make_joints(world, self._stones)
end

function StoneGroup:count()
  local count = 0
  physics.process_colliders(self._stones, function()
    count = count + 1
  end)

  return count
end

function StoneGroup:select_stones(world, x, y, radius)
  local selected_stone = nil
  local minimal_distance = math.huge
  local colliders = world:queryCircleArea(x, y, radius)
  for _, collider in ipairs(colliders) do
    if self._stone_index[collider] then
      local distance = mlib.line.getLength(x, y, collider:getPosition())
      if distance < minimal_distance then
        selected_stone = collider
        minimal_distance = distance
      end
    end
  end

  local selected_stone_pair = nil
  if selected_stone then
    selected_stone_pair = self._stone_pairs[selected_stone]
  end

  return selected_stone, selected_stone_pair
end

function StoneGroup:reset(world, screen, side_count)
  physics.process_colliders(self._stones, function(stone)
    stone:destroy()
  end)

  self:initialize(world, screen, side_count)
end

return StoneGroup
