---
-- @module ui

local suit = require("suit")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Rectangle = require("models.rectangle")
local Stats = require("models.stats")
local UiUpdate = require("models.uiupdate")
local icons = require("constants.icons")

local _ICONS_FONT_PATH =
  "resources/fonts/font-awesome/font_awesome_free_7.3.0_solid_900.otf"

local ui = {}

---
-- @tparam Rectangle screen
-- @treturn {[string]=Font,...}
function ui.load_fonts(screen)
  assertions.is_instance(screen, Rectangle)

  local font_size = screen.height / 25
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
-- @tparam Rectangle screen
-- @tparam {[string]=Font,...} fonts
-- @tparam Stats stats
-- @treturn UiUpdate
function ui.update(screen, fonts, stats)
  assertions.is_instance(screen, Rectangle)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)
  assertions.is_instance(stats, Stats)

  ui._update_labels(screen, fonts, stats)
  return ui._update_buttons(screen, fonts)
end

---
-- @tparam Rectangle screen
-- @tparam {[string]=Font,...} fonts
-- @tparam Stats stats
function ui._update_labels(screen, fonts, stats)
  assertions.is_instance(screen, Rectangle)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)
  assertions.is_instance(stats, Stats)

  local grid_step = screen.height / 10

  -- current stats
  suit.layout:reset(
    screen.x + screen.width - 3.5 * grid_step,
    screen.y + grid_step
  )
  suit.Label(
    "Now:",
    ui._create_label_options(fonts.default, "left"),
    suit.layout:row(1.5 * grid_step, 0.75 * grid_step)
  )
  suit.Label(
    tostring(stats.current),
    ui._create_label_options(fonts.default, "right"),
    suit.layout:col(grid_step, 0.75 * grid_step)
  )

  -- minimal stats
  suit.layout:reset(
    screen.x + screen.width - 3.5 * grid_step,
    screen.y + 1.75 * grid_step
  )
  suit.Label(
    "Min:",
    ui._create_label_options(fonts.default, "left"),
    suit.layout:row(1.5 * grid_step, 0.75 * grid_step)
  )
  suit.Label(
    tostring(stats.minimal),
    ui._create_label_options(fonts.default, "right"),
    suit.layout:col(grid_step, 0.75 * grid_step)
  )
end

---
-- @tparam Rectangle screen
-- @tparam {[string]=Font,...} fonts
-- @treturn UiUpdate
function ui._update_buttons(screen, fonts)
  assertions.is_instance(screen, Rectangle)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)

  local grid_step = screen.height / 10
  suit.layout:reset(screen.x + grid_step, screen.y + grid_step)

  local reset_button = suit.Button(
    icons.RESET_ICON,
    { font = fonts.icons },
    suit.layout:row(grid_step, grid_step)
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
