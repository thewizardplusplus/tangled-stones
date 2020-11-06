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

local function isJointValid(joint)
  return joint and not joint:isDestroyed()
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

  -- stones
  local stone_count = 4
  local prev_stone = nil
  for i = 1, stone_count do
    local stone = makeRectangle(world, {
      kind = "dynamic",
      x = x + width / (stone_count + 1) * i - grid_step / 2,
      y = y + (height - grid_step) / 2,
      width = grid_step,
      height = grid_step,
    })
    if prev_stone then
      local x1, y1 = prev_stone:getPosition()
      local x2, y2 = stone:getPosition()
      world:addJoint(
        "RopeJoint",
        prev_stone,
        stone,
        x1, y1,
        x2, y2,
        math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2),
        true
      )

      prev_stone = nil
    else
      prev_stone = stone
    end
  end
end

function love.draw()
  world:draw()

  -- draw joints
  love.graphics.setColor(222, 128, 64, 255)
  for _, joint in ipairs(world:getJoints()) do
    local x1, y1, x2, y2 = joint:getAnchors()
    if x1 and y1 and x2 and y2 then
      love.graphics.line(x1, y1, x2, y2)
    end
  end
end

function love.update(dt)
  if isJointValid(joint) then
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
  local first_dynamic_collider = nil
  local colliders = world:queryCircleArea(x, y, 1.5 * grid_step / 2)
  for _, collider in ipairs(colliders) do
    if collider.body:getType() == "dynamic" then
      first_dynamic_collider = collider
      break
    end
  end
  if first_dynamic_collider then
    joint = world:addJoint("MouseJoint", first_dynamic_collider, x, y)
  end
end

function love.mousereleased()
  if isJointValid(joint) then
    joint:destroy()
  end
end
