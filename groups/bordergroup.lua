local middleclass = require("middleclass")
local Rectangle = require("models.rectangle")
local physics = require("physics")

local BorderGroup = middleclass("BorderGroup")

function BorderGroup:initialize(world, screen)
  local grid_step = screen.height / 10
  self._bottom_limit = screen.y + screen.height - grid_step

  local top = physics.make_collider(world, "static", Rectangle:new(
    screen.x + grid_step,
    screen.y,
    screen.width - 2 * grid_step,
    grid_step
  ))
  local bottom_left = physics.make_collider(world, "static", Rectangle:new(
    screen.x + grid_step,
    self._bottom_limit,
    (screen.width - 3.5 * grid_step) / 2,
    grid_step
  ))
  local bottom_right = physics.make_collider(world, "static", Rectangle:new(
    screen.x + (screen.width + 1.5 * grid_step) / 2,
    self._bottom_limit,
    (screen.width - 3.5 * grid_step) / 2,
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

function BorderGroup:is_out(stone)
  local _, y = stone:getPosition()
  return y > self._bottom_limit
end

function BorderGroup:reset(world, screen)
  physics.process_colliders(self._borders, function(border)
    border:destroy()
  end)

  self:initialize(world, screen)
end

return BorderGroup
