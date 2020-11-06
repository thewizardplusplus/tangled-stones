package.path = "/sdcard/lovegame/vendor/?.lua;"
  .. "/sdcard/lovegame/vendor/?/init.lua;"
  .. "./vendor/?.lua;"
  .. "./vendor/?/init.lua"

local windfield = require("windfield")

local world = nil -- love.physics.World
local grid_step = 0
local stones = {}
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

local function shuffle(array)
  -- Fisher-Yates shuffle
  for i = 1, #array do
    local j = math.random(i, #array)
    array[i], array[j] = array[j], array[i]
  end
end

local function getVectorLength(x1, y1, x2, y2)
  return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end

local function isJointValid(joint)
  return joint and not joint:isDestroyed()
end

function love.load()
  math.randomseed(os.time())

  world = windfield.newWorld(0, 0, true)
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
  local stones_side_count = 5
  local stones_x = x + width / 2 - stones_side_count * grid_step / 2
  local stones_y = y + height / 2 - stones_side_count * grid_step / 2
  for row = 0, stones_side_count - 1 do
    for column = 0, stones_side_count - 1 do
      local stone = makeRectangle(world, {
        kind = "static",
        x = stones_x + column * grid_step,
        y = stones_y + row * grid_step,
        width = grid_step,
        height = grid_step,
      })
      table.insert(stones, stone)
    end
  end
  shuffle(stones)

  local prev_stone = nil
  for _, stone in ipairs(stones) do
    if prev_stone then
      local x1, y1 = prev_stone:getPosition()
      local x2, y2 = stone:getPosition()
      world:addJoint(
        "RopeJoint",
        prev_stone,
        stone,
        x1, y1,
        x2, y2,
        getVectorLength(x1, y1, x2, y2),
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
  for _, stone in ipairs(stones) do
    stone.body:setType("dynamic")
  end

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

  for _, stone in ipairs(stones) do
    if first_dynamic_collider and stone == first_dynamic_collider then
      stone.body:setType("dynamic")
    else
      stone.body:setType("static")
    end
  end
end

function love.mousereleased()
  if isJointValid(joint) then
    joint:destroy()
  end
end
