---
-- @module ui

local suit = require("suit")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Vector2D = require("luamath.vector2d")
local Matrix3x3 = require("luamath.matrix3x3")
local BoundingBox = require("luamath.models.boundingbox")
local Size = require("luamath.models.size")
local Stats = require("models.stats")
local UiUpdate = require("models.uiupdate")
local icons = require("constants.icons")

local _ICONS_FONT_PATH =
  "resources/fonts/font-awesome/font_awesome_free_7.3.0_solid_900.otf"

local ui = {}

---
-- @tparam BoundingBox screen
-- @treturn {[string]=Font,...}
function ui.load_fonts(screen)
  assertions.is_instance(screen, BoundingBox)

  local font_size = screen:size().height / 25
  return {
    default = love.graphics.newFont(font_size),
    icons = love.graphics.newFont(_ICONS_FONT_PATH, font_size),
  }
end

---
-- @function draw
function ui.draw()
  suit.draw()
end

---
-- @tparam BoundingBox screen
-- @tparam {[string]=Font,...} fonts
-- @tparam Stats stats
-- @treturn UiUpdate
function ui.update(screen, fonts, stats)
  assertions.is_instance(screen, BoundingBox)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)
  assertions.is_instance(stats, Stats)

  ui._update_labels(screen, fonts, stats)
  return ui._update_buttons(screen, fonts)
end

---
-- @tparam BoundingBox screen
-- @tparam {[string]=Font,...} fonts
-- @tparam Stats stats
function ui._update_labels(screen, fonts, stats)
  assertions.is_instance(screen, BoundingBox)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)
  assertions.is_instance(stats, Stats)

  local grid_step = screen:y_range():length() / 10
  local label_size = Size:new(1.5 * grid_step, 0.75 * grid_step)
  local value_size = Size:new(grid_step, 0.75 * grid_step)
  local screen_transform = Matrix3x3.translate(screen:position())

  -- current stats
  local current_stats_position = screen_transform * Vector2D:new(
    screen:x_range():length() - 3.5 * grid_step,
    grid_step
  )
  suit.layout:reset(current_stats_position.x, current_stats_position.y)
  suit.Label(
    "Now:",
    ui._create_label_options(fonts.default, "left"),
    suit.layout:row(label_size.width, label_size.height)
  )
  suit.Label(
    tostring(stats.current),
    ui._create_label_options(fonts.default, "right"),
    suit.layout:col(value_size.width, value_size.height)
  )

  -- minimal stats
  local minimal_stats_position = screen_transform * Vector2D:new(
    screen:x_range():length() - 3.5 * grid_step,
    1.75 * grid_step
  )
  suit.layout:reset(minimal_stats_position.x, minimal_stats_position.y)
  suit.Label(
    "Min:",
    ui._create_label_options(fonts.default, "left"),
    suit.layout:row(label_size.width, label_size.height)
  )
  suit.Label(
    tostring(stats.minimal),
    ui._create_label_options(fonts.default, "right"),
    suit.layout:col(value_size.width, value_size.height)
  )
end

---
-- @tparam BoundingBox screen
-- @tparam {[string]=Font,...} fonts
-- @treturn UiUpdate
function ui._update_buttons(screen, fonts)
  assertions.is_instance(screen, BoundingBox)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)

  local grid_step = screen:y_range():length() / 10
  local button_size = Size:new(grid_step, grid_step)
  local position = Matrix3x3.translate(screen:position())
    * Vector2D:new(grid_step, grid_step)
  suit.layout:reset(position.x, position.y)

  local reset_button = suit.Button(
    icons.RESET_ICON,
    { font = fonts.icons },
    suit.layout:row(button_size.width, button_size.height)
  )
  return UiUpdate:new(reset_button.hit)
end

---
-- @tparam Font font
-- @tparam "left"|"right" align
-- @treturn tab common SUIT widget options
function ui._create_label_options(font, align)
  assertions.is_true(type(font) == "userdata")
  assertions.is_enumeration(align, {"left", "right"})

  return {
    font = font,
    align = align,
    valign = "top",
    color = { normal = { fg = {1, 1, 1} } },
  }
end

return ui
