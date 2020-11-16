package.path = "/sdcard/lovegame/vendor/?.lua;"
  .. "/sdcard/lovegame/vendor/?/init.lua;"
  .. "./vendor/?.lua;"
  .. "./vendor/?/init.lua"

local windfield = require("windfield")
local mlib = require("mlib")
local suit = require("suit")
local Rectangle = require("models.rectangle")
local statsfactory = require("stats.statsfactory")
local ui = require("ui")
local physics = require("physics")

local STONES_SIDE_COUNT = 5
local INITIAL_STATS_MINIMAL = 100

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
local stats_storage = nil -- stats.StatsStorage

local function shuffle(array)
  -- Fisher-Yates shuffle
  for i = 1, #array do
    local j = math.random(i, #array)
    array[i], array[j] = array[j], array[i]
  end
end

local function makeStones(world, side_count, grid_step, offset_x, offset_y)
  local stones = {}
  for row = 0, side_count - 1 do
    for column = 0, side_count - 1 do
      local stone = physics.make_collider(world, "static", Rectangle:new(
        offset_x + column * grid_step,
        offset_y + row * grid_step,
        grid_step,
        grid_step
      ))
      table.insert(stones, stone)
    end
  end
  shuffle(stones)

  local stones_joints = {}
  local prev_stone = nil
  physics.process_colliders(stones, function(stone)
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

function love.load()
  math.randomseed(os.time())

  local x, y, width, height = love.window.getSafeArea()
  grid_step = height / 10

  world = windfield.newWorld(0, 0, true)
  world:setQueryDebugDrawing(true)

  bottom_limit = y + height - grid_step
  -- top
  physics.make_collider(world, "static", Rectangle:new(
    x + grid_step,
    y,
    width - 2 * grid_step,
    grid_step
  ))
  -- bottom left
  physics.make_collider(world, "static", Rectangle:new(
    x + grid_step,
    bottom_limit,
    (width - 3.5 * grid_step) / 2,
    grid_step
  ))
  -- bottom right
  physics.make_collider(world, "static", Rectangle:new(
    x + (width + 1.5 * grid_step) / 2,
    bottom_limit,
    (width - 3.5 * grid_step) / 2,
    grid_step
  ))
  -- left
  physics.make_collider(world, "static", Rectangle:new(
    x,
    y,
    grid_step,
    height
  ))
  -- right
  physics.make_collider(world, "static", Rectangle:new(
    x + width - grid_step,
    y,
    grid_step,
    height
  ))

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

  stats_storage =
    assert(statsfactory.create_stats_storage("stats-db", INITIAL_STATS_MINIMAL))
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
  if selection_joint then
    selection_joint:setTarget(love.mouse.getPosition())
  end

  world:update(dt)

  local x, y, width, height = love.window.getSafeArea()
  local screen = Rectangle:new(x, y, width, height)
  local update = ui.update(screen, stats_storage:stats())
  if update.reset then
    physics.process_colliders(stones, function(stone)
      stone:destroy()
    end)

    stones, stones_joints = makeStones(
      world,
      STONES_SIDE_COUNT,
      grid_step,
      stones_offset_x,
      stones_offset_y
    )

    stats_storage:reset()
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

function love.mousepressed(x, y)
  physics.set_kind_of_colliders("dynamic", stones)

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

  physics.set_kind_of_colliders("static", stones, function(stone)
    return stone ~= selected_stone and stone ~= selected_stone_pair
  end)
end

function love.mousereleased()
  if selection_joint then
    selection_joint:destroy()
    selection_joint = nil
  end

  local selected_stones = {selected_stone, selected_stone_pair}
  physics.set_kind_of_colliders("static", selected_stones)

  if selected_stone then
    local _, y = selected_stone:getPosition()
    if y > bottom_limit then
      selected_stone:destroy()
    end

    stats_storage:increment()
  end

  local valid_stone_count = 0
  physics.process_colliders(stones, function()
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

    stats_storage:finish()
  end
end
