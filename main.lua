local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local windfield = require("windfield")
local assertions = require("luatypechecks.assertions")
local BorderGroup = require("groups.bordergroup")
local StoneGroup = require("groups.stonegroup")
local SettingsStorage = require("storages.settingsstorage")
local StatsStorage = require("storages.statsstorage")
local window = require("window")
local ui = require("ui")
local physics = require("physics")
require("luatable")

local world = nil -- windfield.World
local screen = nil -- models.Rectangle
local stones = nil -- groups.StoneGroup
local borders = nil -- groups.BorderGroup
local selection = nil -- models.Selection
local settings_storage = nil -- storages.SettingsStorage
local stats_storage = nil -- storages.StatsStorage

function love.load()
  math.randomseed(os.time())
  love.setDeprecationOutput(true)
  assert(window.enter_fullscreen())

  world = windfield.newWorld(0, 0, true)
  world:setQueryDebugDrawing(true)

  screen = window.create_screen()
  settings_storage = SettingsStorage:new("settings.json")

  local settings = settings_storage:settings()
  stones = StoneGroup:new(world, screen, settings.side_count)
  borders = BorderGroup:new(world, screen, stones:stone_size())

  stats_storage = StatsStorage:new("stats.json", settings.side_count)
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

  local update = ui.update(screen, stats_storage:stats_group():stats())
  if update.reset then
    stones:reset(world, screen, settings_storage:settings().side_count)
    stats_storage:stats_group():reset()
  end
end

function love.resize()
  screen = window.create_screen()
  stones:reset(world, screen, settings_storage:settings().side_count)
  borders:reset(world, screen, stones:stone_size())
  stats_storage:stats_group():reset()
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
    stats_storage:stats_group():increment()
  end

  physics.process_colliders(selection:stones(), function(stone)
    assertions.is_table(stone)

    if borders:is_out(stone) then
      stone:destroy()
    end
  end)
  if stones:count() == 0 then
    local was_updated = stats_storage:stats_group():finish()
    if was_updated then
      stats_storage:save()
    end

    local settings = settings_storage:settings()
    if settings.auto_increment_side_count then
      settings.side_count = settings.side_count + 1
      settings_storage:save()

      stats_storage:stats_group():set_side_count(settings.side_count)
    end

    stones:reset(world, screen, settings.side_count)
    if settings.auto_increment_side_count then
      borders:reset(world, screen, stones:stone_size())
    end
  end
end
