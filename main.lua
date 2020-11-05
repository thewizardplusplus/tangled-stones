package.path = "/sdcard/lovegame/vendor/?.lua;"
  .. "/sdcard/lovegame/vendor/?/init.lua;"
  .. "./vendor/?.lua;"
  .. "./vendor/?/init.lua"

local windfield = require("windfield")

local world = nil -- love.physics.World
local grid_step = 0
local joint = nil -- love.physics.MouseJoint

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
  world:setQueryDebugDrawing(true)

  local x, y, width, height = love.window.getSafeArea()
  grid_step = height / 10
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
  if joint and not joint:isDestroyed() then
    joint:setTarget(love.mouse.getPosition())
  end

  world:update(dt)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

function love.mousepressed(x, y)
  local colliders = world:queryCircleArea(x, y, 1.5 * grid_step / 2)
  if #colliders == 0 then
    return
  end

  joint = world:addJoint("MouseJoint", colliders[1], x, y) 
end

function love.mousereleased()
  if joint and not joint:isDestroyed() then
    joint:destroy()
  end
end
