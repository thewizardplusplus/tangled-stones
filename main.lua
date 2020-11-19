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
local screen = nil -- Rectangle
local bottom_limit = 0
local stones = nil -- StoneGroup
local selection = nil -- Selection
local selection_joint = nil -- love.physics.MouseJoint
local stats_storage = nil -- stats.StatsStorage

local function make_screen()
  local x, y, width, height = love.window.getSafeArea()
  return Rectangle:new(x, y, width, height)
end

function love.load()
  math.randomseed(os.time())

  screen = make_screen()
  local grid_step = screen.height / 10

  world = windfield.newWorld(0, 0, true)
  world:setQueryDebugDrawing(true)

  bottom_limit = screen.y + screen.height - grid_step
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
    bottom_limit,
    (screen.width - 3.5 * grid_step) / 2,
    grid_step
  ))
  -- bottom right
  physics.make_collider(world, "static", Rectangle:new(
    screen.x + (screen.width + 1.5 * grid_step) / 2,
    bottom_limit,
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

  stones = StoneGroup:new(world, screen, STONES_SIDE_COUNT)
  stats_storage =
    assert(statsfactory.create_stats_storage("stats-db", INITIAL_STATS_MINIMAL))
end

function love.draw()
  physics.draw(world)
  ui.draw(screen)
end

function love.update(dt)
  if selection_joint then
    selection_joint:setTarget(love.mouse.getPosition())
  end

  world:update(dt)

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
  selection = stones:select_stones(world, x, y)
  selection:activate(world, x, y)
  selection_joint = selection.stone_joint
end

function love.mousereleased()
  if selection_joint then
    selection_joint:destroy()
    selection_joint = nil
  end

  selection:set_kind("static")

  if selection.primary_stone then
    local _, y = selection.primary_stone:getPosition()
    if y > bottom_limit then
      selection.primary_stone:destroy()
    end

    stats_storage:increment()
  end

  if stones:count() == 0 then
    stones:reset(world, screen, STONES_SIDE_COUNT)
    stats_storage:finish()
  end
end
