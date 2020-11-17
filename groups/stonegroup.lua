local middleclass = require("middleclass")
local mlib = require("mlib")
local Rectangle = require("models.rectangle")
local physics = require("physics")

local function shuffle(array)
  -- Fisher-Yates shuffle
  for i = 1, #array do
    local j = math.random(i, #array)
    array[i], array[j] = array[j], array[i]
  end
end

local StoneGroup = middleclass("StoneGroup")

function StoneGroup:initialize(world, screen, side_count)
  self._stones = {}
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
      table.insert(self._stones, stone)
    end
  end
  shuffle(self._stones)

  self._pairs = {}
  local prev_stone = nil
  physics.process_colliders(self._stones, function(stone)
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

    self._pairs[prev_stone] = stone
    self._pairs[stone] = prev_stone

    prev_stone = nil
  end)
end

function StoneGroup:reset(world, screen, side_count)
  physics.process_colliders(self._stones, function(stone)
    stone:destroy()
  end)

  self:initialize(world, screen, side_count)
end

return StoneGroup
