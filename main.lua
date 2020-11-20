package.path = "/sdcard/lovegame/vendor/?.lua;"
  .. "/sdcard/lovegame/vendor/?/init.lua;"
  .. "./vendor/?.lua;"
  .. "./vendor/?/init.lua"

local windfield = require("windfield")
local mlib = require("mlib")
local suit = require("suit")
local Rectangle = require("models.rectangle")
local BorderGroup = require("groups.bordergroup")
local StoneGroup = require("groups.stonegroup")
local statsfactory = require("stats.statsfactory")
local ui = require("ui")
local physics = require("physics")
require("luatable")

local STONES_SIDE_COUNT = 5
local INITIAL_STATS_MINIMAL = 100

local world = nil -- love.physics.World
local screen = nil -- models.Rectangle
local borders = nil -- groups.BorderGroup
local stones = nil -- groups.StoneGroup
local selection = nil -- models.Selection
local stats_storage = nil -- stats.StatsStorage

local function _make_screen()
  local x, y, width, height = love.window.getSafeArea()
  return Rectangle:new(x, y, width, height)
end

function love.load()
  math.randomseed(os.time())

  world = windfield.newWorld(0, 0, true)
  world:setQueryDebugDrawing(true)

  screen = _make_screen()
  borders = BorderGroup:new(world, screen)
  stones = StoneGroup:new(world, screen, STONES_SIDE_COUNT)
  stats_storage =
    assert(statsfactory.create_stats_storage("stats-db", INITIAL_STATS_MINIMAL))
end

function love.draw()
  physics.draw(world)
  ui.draw(screen)
end

function love.update(dt)
  if selection then
    selection:update(love.mouse.getPosition())
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
end

function love.mousereleased()
  selection:deactivate()

  if selection.primary_stone then
    stats_storage:increment()
  end

  physics.process_colliders(selection:stones(), function(stone)
    if borders:is_out(stone) then
      stone:destroy()
    end
  end)
  if stones:count() == 0 then
    stones:reset(world, screen, STONES_SIDE_COUNT)
    stats_storage:finish()
  end
end
