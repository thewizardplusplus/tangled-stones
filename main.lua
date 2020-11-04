package.path = "/sdcard/lovegame/vendor/?.lua;"
  .. "/sdcard/lovegame/vendor/?/init.lua;"
  .. "./vendor/?.lua;"
  .. "./vendor/?/init.lua"

local windfield = require("windfield")

local world = nil -- love.physics.World

local function makeRectangle(world, options)
  local rectangle = world:newRectangleCollider(
    options.x,
    options.y,
    options.width,
    options.height
  )
  rectangle:setType(options.kind)

  return rectangle
end

function love.load()
  world = windfield.newWorld(0, 9.8, true)

  local x, y, width, height = love.window.getSafeArea()
  local grid_step = height / 10
  -- top
  makeRectangle(world, {
    kind = "static",
    x = x + grid_step,
    y = y,
    width = width - 2 * grid_step,
    height = grid_step,
  })
  -- bottom
  makeRectangle(world, {
    kind = "static",
    x = x + grid_step,
    y = y + height - grid_step,
    width = width - 2 * grid_step,
    height = grid_step,
  })
  -- left
  makeRectangle(world, {
    kind = "static",
    x = x,
    y = y,
    width = grid_step,
    height = height,
  })
  -- right
  makeRectangle(world, {
    kind = "static",
    x = x + width - grid_step,
    y = y,
    width = grid_step,
    height = height,
  })

  -- stone
  makeRectangle(world, {
    kind = "dynamic",
    x = x + (width - grid_step) / 2,
    y = y + (height - grid_step) / 2,
    width = grid_step,
    height = grid_step,
  })
end

function love.draw()
  world:draw()
end

function love.update(dt)
  world:update(dt)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
