package.path = "/sdcard/lovegame/vendor/?.lua;"
  .. "/sdcard/lovegame/vendor/?/init.lua;"
  .. "./vendor/?.lua;"
  .. "./vendor/?/init.lua"

local windfield = require("windfield")
local mlib = require("mlib")
local suit = require("suit")

local STONES_SIDE_COUNT = 5

local world = nil -- love.physics.World
local grid_step = 0
local bottom_limit = 0
local stones_offset_x = 0
local stones_offset_y = 0
local stones = {} -- array<windfield.Collider>
local stones_joints = {} -- map<windfield.Collider, windfield.Collider>
local selection_joint = nil -- love.physics.MouseJoint
local selected_stone = nil -- windfield.Collider
local selected_stone_pair = nil -- windfield.Collider

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

local function isEntityValid(entity)
  return entity and not entity:isDestroyed()
end

local function processColliders(colliders, handler)
  for _, collider in ipairs(colliders) do
    if isEntityValid(collider) then
      handler(collider)
    end
  end
end

local function makeStones(world, side_count, grid_step, offset_x, offset_y)
  local stones = {}
  for row = 0, side_count - 1 do
    for column = 0, side_count - 1 do
      local stone = makeRectangle(world, {
        kind = "static",
        x = offset_x + column * grid_step,
        y = offset_y + row * grid_step,
        width = grid_step,
        height = grid_step,
      })
      table.insert(stones, stone)
    end
  end
  shuffle(stones)

  local stones_joints = {}
  local prev_stone = nil
  processColliders(stones, function(stone)
    if prev_stone then
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

      stones_joints[prev_stone] = stone
      stones_joints[stone] = prev_stone

      prev_stone = nil
    else
      prev_stone = stone
    end
  end)

  return stones, stones_joints
end

local function setCollidersKind(colliders, kind, filter)
  filter = filter or function() return true end

  processColliders(colliders, function(collider)
    if filter(collider) then
      collider.body:setType(kind)
    end
  end)
end

function love.load()
  math.randomseed(os.time())

  world = windfield.newWorld(0, 0, true)
  world:setQueryDebugDrawing(true)

  local x, y, width, height = love.window.getSafeArea()
  grid_step = height / 10
  bottom_limit = y + height - grid_step
  -- top
  makeRectangle(world, {
    kind = "static",
    x = x + grid_step,
    y = y,
    width = width - 2 * grid_step,
    height = grid_step,
  })
  -- bottom left
  makeRectangle(world, {
    kind = "static",
    x = x + grid_step,
    y = bottom_limit,
    width = (width - 3.5 * grid_step) / 2,
    height = grid_step,
  })
  -- bottom right
  makeRectangle(world, {
    kind = "static",
    x = x + (width + 1.5 * grid_step) / 2,
    y = bottom_limit,
    width = (width - 3.5 * grid_step) / 2,
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
  stones_offset_x = x + width / 2 - STONES_SIDE_COUNT * grid_step / 2
  stones_offset_y = y + height / 2 - STONES_SIDE_COUNT * grid_step / 2
  stones, stones_joints = makeStones(
    world,
    STONES_SIDE_COUNT,
    grid_step,
    stones_offset_x,
    stones_offset_y
  )
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

  suit.draw()
end

function love.update(dt)
  if isEntityValid(selection_joint) then
    selection_joint:setTarget(love.mouse.getPosition())
  end

  world:update(dt)

  local x, y = love.window.getSafeArea()
  suit.layout:reset(x + grid_step / 2, y + grid_step / 2)

  local reset_button = suit.Button("@", suit.layout:row(grid_step, grid_step))
  if reset_button.hit then
    processColliders(stones, function(stone)
      stone:destroy()
    end)

    stones, stones_joints = makeStones(
      world,
      STONES_SIDE_COUNT,
      grid_step,
      stones_offset_x,
      stones_offset_y
    )
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

function love.mousepressed(x, y)
  setCollidersKind(stones, "dynamic")

  selected_stone = nil
  local minimal_distance = math.huge
  local colliders = world:queryCircleArea(x, y, 1.5 * grid_step / 2)
  for _, collider in ipairs(colliders) do
    if collider.body:getType() == "dynamic" then
      local distance = mlib.line.getLength(x, y, collider:getPosition())
      if distance < minimal_distance then
        selected_stone = collider
        minimal_distance = distance
      end
    end
  end

  selected_stone_pair = nil
  if selected_stone then
    selection_joint = world:addJoint("MouseJoint", selected_stone, x, y)
    selected_stone_pair = stones_joints[selected_stone]
  end

  setCollidersKind(stones, "static", function(stone)
    return stone ~= selected_stone and stone ~= selected_stone_pair
  end)
end

function love.mousereleased()
  if isEntityValid(selection_joint) then
    selection_joint:destroy()
  end

  local selected_stones = {selected_stone, selected_stone_pair}
  setCollidersKind(selected_stones, "static")

  if selected_stone then
    local _, y = selected_stone:getPosition()
    if y > bottom_limit then
      selected_stone:destroy()
    end
  end

  local valid_stone_count = 0
  processColliders(stones, function()
    valid_stone_count = valid_stone_count + 1
  end)
  if valid_stone_count == 0 then
    stones, stones_joints = makeStones(
      world,
      STONES_SIDE_COUNT,
      grid_step,
      stones_offset_x,
      stones_offset_y
    )
  end
end
