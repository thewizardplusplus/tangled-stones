package.path = "/sdcard/lovegame/vendor/?.lua;"
  .. "/sdcard/lovegame/vendor/?/init.lua;"
  .. "./vendor/?.lua;"
  .. "./vendor/?/init.lua"

local windfield = require("windfield")
local mlib = require("mlib")
local suit = require("suit")
local Rectangle = require("models.rectangle")
local StoneGroup = require("groups.stonegroup")
local statsfactory = require("stats.statsfactory")
local ui = require("ui")
local physics = require("physics")

local STONES_SIDE_COUNT = 5
local INITIAL_STATS_MINIMAL = 100

local world = nil -- love.physics.World
local grid_step = 0
local bottom_limit = 0
local stones = nil -- StoneGroup
local selection_joint = nil -- love.physics.MouseJoint
local selected_stone = nil -- windfield.Collider
local selected_stone_pair = nil -- windfield.Collider
local stats_storage = nil -- stats.StatsStorage

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
  local screen = Rectangle:new(x, y, width, height)
  stones = StoneGroup:new(world, screen, STONES_SIDE_COUNT)

  stats_storage =
    assert(statsfactory.create_stats_storage("stats-db", INITIAL_STATS_MINIMAL))
end

function love.draw()
  physics.draw(world)

  local x, y, width, height = love.window.getSafeArea()
  local screen = Rectangle:new(x, y, width, height)
  ui.draw(screen)
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
    stones:reset(world, screen, STONES_SIDE_COUNT)
    stats_storage:reset()
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

function love.mousepressed(x, y)
  selected_stone, selected_stone_pair = stones:select_stones(world, x, y, 1.5 * grid_step / 2)

  local selected_stones = {selected_stone, selected_stone_pair}
  physics.set_kind_of_colliders("dynamic", selected_stones)

  if selected_stone then
    selection_joint = world:addJoint("MouseJoint", selected_stone, x, y)
  end
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

  if stones:count() == 0 then
    local x, y, width, height = love.window.getSafeArea()
    local screen = Rectangle:new(x, y, width, height)
    stones:reset(world, screen, STONES_SIDE_COUNT)

    stats_storage:finish()
  end
end
