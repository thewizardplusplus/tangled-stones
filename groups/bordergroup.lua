local middleclass = require("middleclass")
local Rectangle = require("models.rectangle")
local physics = require("physics")

local BorderGroup = middleclass("BorderGroup")

function BorderGroup:initialize(world, screen)
  local grid_step = screen.height / 10
  self._bottom_limit = screen.y + screen.height - grid_step
  -- top
  physics.make_collider(world, "static", Rectangle:new(
    screen.x + grid_step,
    screen.y,
    screen.width - 2 * grid_step,
    grid_step
  ))
  -- bottom left
  physics.make_collider(world, "static", Rectangle:new(
    screen.x + grid_step,
    self._bottom_limit,
    (screen.width - 3.5 * grid_step) / 2,
    grid_step
  ))
  -- bottom right
  physics.make_collider(world, "static", Rectangle:new(
    screen.x + (screen.width + 1.5 * grid_step) / 2,
    self._bottom_limit,
    (screen.width - 3.5 * grid_step) / 2,
    grid_step
  ))
  -- left
  physics.make_collider(world, "static", Rectangle:new(
    screen.x,
    screen.y,
    grid_step,
    screen.height
  ))
  -- right
  physics.make_collider(world, "static", Rectangle:new(
    screen.x + screen.width - grid_step,
    screen.y,
    grid_step,
    screen.height
  ))
end

function BorderGroup:is_out(stone)
  local _, y = stone:getPosition()
  return y > self._bottom_limit
end

return BorderGroup
