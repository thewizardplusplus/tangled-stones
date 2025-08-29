local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local windfield = require("windfield")
local assertions = require("luatypechecks.assertions")
local jsonutils = require("jsonutils")
local Rectangle = require("models.rectangle")
local GameSettings = require("models.gamesettings")
local BorderGroup = require("groups.bordergroup")
local StoneGroup = require("groups.stonegroup")
local statsfactory = require("stats.statsfactory")
local ui = require("ui")
local physics = require("physics")
require("luatable")
require("compat52")

local world = nil -- windfield.World
local screen = nil -- models.Rectangle
local settings = nil -- models.GameSettings
local stones = nil -- groups.StoneGroup
local borders = nil -- groups.BorderGroup
local selection = nil -- models.Selection
local stats_storage = nil -- stats.StatsStorage

local function _enter_fullscreen()
  local is_mobile_os = love.system.getOS() == "Android"
    or love.system.getOS() == "iOS"
  if not is_mobile_os then
    return true
  end

  local ok = love.window.setFullscreen(true, "desktop")
  if not ok then
    return false, "unable to enter fullscreen"
  end

  return true
end

local function _make_screen()
  local x, y, width, height = love.window.getSafeArea()
  return Rectangle:new(x, y, width, height)
end

local function _load_game_settings(path)
  assertions.is_string(path)

  local settings, err = jsonutils.load_from_json(
    path,
    {
      type = "object",
      required = {"side_count"},
      properties = {
        side_count = {
          type = "number",
          minimum = 0,
        },
      },
    },
    {
      GameSettings = function(options)
        assertions.is_table(options)

        return GameSettings:new(options.side_count)
      end,
    }
  )
  if not settings then
    return nil, "unable to load the game settings: " .. err
  end

  return settings
end

function love.load()
  math.randomseed(os.time())
  love.setDeprecationOutput(true)
  assert(_enter_fullscreen())

  world = windfield.newWorld(0, 0, true)
  world:setQueryDebugDrawing(true)

  screen = _make_screen()
  settings = assert(_load_game_settings("game_settings.json"))
  stones = StoneGroup:new(world, screen, settings.side_count)
  borders = BorderGroup:new(world, screen, stones:stone_size())

  local initial_stats_minimal = math.pow(settings.side_count, 2) * 10
  stats_storage =
    assert(statsfactory.create_stats_storage("stats-db", initial_stats_minimal))
end

function love.draw()
  physics.draw(world)
  ui.draw(screen)
end

function love.update(dt)
  assertions.is_number(dt)

  if selection then
    selection:update(love.mouse.getPosition())
  end
  world:update(dt)

  local update = ui.update(screen, stats_storage:stats())
  if update.reset then
    stones:reset(world, screen, settings.side_count)
    stats_storage:reset()
  end
end

function love.resize()
  screen = _make_screen()
  stones:reset(world, screen, settings.side_count)
  borders:reset(world, screen, stones:stone_size())
  stats_storage:reset()
end

function love.keypressed(key)
  assertions.is_string(key)

  if key == "escape" then
    love.event.quit()
  end
end

function love.mousepressed(x, y)
  assertions.is_number(x)
  assertions.is_number(y)

  if selection and selection:is_activated() then
    return
  end

  selection = stones:select_stones(world, x, y)
  selection:activate(world, x, y)
end

function love.mousereleased()
  selection:deactivate()

  if selection.primary_stone then
    stats_storage:increment()
  end

  physics.process_colliders(selection:stones(), function(stone)
    assertions.is_table(stone)

    if borders:is_out(stone) then
      stone:destroy()
    end
  end)
  if stones:count() == 0 then
    stones:reset(world, screen, settings.side_count)
    stats_storage:finish()
  end
end
