---
-- @module ui

local suit = require("suit")
local assertions = require("luatypechecks.assertions")
local Rectangle = require("models.rectangle")
local Stats = require("models.stats")
local UiUpdate = require("models.uiupdate")

local ui = {}

---
-- @tparam Rectangle screen
function ui.draw(screen)
  assertions.is_instance(screen, Rectangle)

  local font_size = screen.height / 25
  love.graphics.setFont(love.graphics.newFont(font_size))

  suit.draw()
end

---
-- @tparam Rectangle screen
-- @tparam int side_count [1, ∞)
-- @tparam Stats stats
-- @treturn UiUpdate
function ui.update(screen, side_count, stats)
  assertions.is_instance(screen, Rectangle)
  assertions.is_integer(side_count)
  assertions.is_instance(stats, Stats)

  ui._update_labels(screen, side_count, stats)
  return ui._update_buttons(screen)
end

---
-- @tparam Rectangle screen
-- @tparam int side_count [1, ∞)
-- @tparam Stats stats
function ui._update_labels(screen, side_count, stats)
  assertions.is_instance(screen, Rectangle)
  assertions.is_integer(side_count)
  assertions.is_instance(stats, Stats)

  local grid_step = screen.height / 10

  -- level size
  suit.layout:reset(
    screen.x + screen.width - 3.375 * grid_step,
    screen.y + grid_step
  )
  suit.Label(
    "Size:",
    ui._create_label_options("left"),
    suit.layout:row(1.25 * grid_step, 0.75 * grid_step)
  )
  suit.Label(
    side_count,
    ui._create_label_options("right"),
    suit.layout:col(1.125 * grid_step, 0.75 * grid_step)
  )

  -- current stats
  suit.layout:reset(
    screen.x + screen.width - 3.375 * grid_step,
    screen.y + 1.75 * grid_step
  )
  suit.Label(
    "Now:",
    ui._create_label_options("left"),
    suit.layout:row(1.25 * grid_step, 0.75 * grid_step)
  )
  suit.Label(
    tostring(stats.current),
    ui._create_label_options("right"),
    suit.layout:col(1.125 * grid_step, 0.75 * grid_step)
  )

  -- minimal stats
  suit.layout:reset(
    screen.x + screen.width - 3.375 * grid_step,
    screen.y + 2.5 * grid_step
  )
  suit.Label(
    "Min:",
    ui._create_label_options("left"),
    suit.layout:row(1.25 * grid_step, 0.75 * grid_step)
  )
  suit.Label(
    tostring(stats.minimal),
    ui._create_label_options("right"),
    suit.layout:col(1.125 * grid_step, 0.75 * grid_step)
  )
end

---
-- @tparam Rectangle screen
-- @treturn UiUpdate
function ui._update_buttons(screen)
  assertions.is_instance(screen, Rectangle)

  local grid_step = screen.height / 10
  suit.layout:reset(screen.x + grid_step, screen.y + grid_step)

  local reset_button = suit.Button("@", suit.layout:row(grid_step, grid_step))
  return UiUpdate:new(reset_button.hit)
end

---
-- @tparam "left"|"right" align
-- @treturn tab common SUIT widget options
function ui._create_label_options(align)
  assertions.is_enumeration(align, {"left", "right"})

  return {
    color = {normal = {fg = {1, 1, 1}}},
    align = align,
    valign = "top",
  }
end

return ui
