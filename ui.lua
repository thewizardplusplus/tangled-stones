local suit = require("suit")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")
local Stats = require("models.stats")
local UiUpdate = require("models.uiupdate")

local ui = {}

function ui.draw(screen)
  assert(typeutils.is_instance(screen, Rectangle))

  local font_size = screen.height / 25
  love.graphics.setFont(love.graphics.newFont(font_size))

  suit.draw()
end

function ui.update(screen, stats)
  assert(typeutils.is_instance(screen, Rectangle))
  assert(typeutils.is_instance(stats, Stats))

  ui._update_labels(screen, stats)
  return ui._update_buttons(screen)
end

function ui._update_labels(screen, stats)
  assert(typeutils.is_instance(screen, Rectangle))
  assert(typeutils.is_instance(stats, Stats))

  local grid_step = screen.height / 10

  -- current stats
  suit.layout:reset(
    screen.x + screen.width - 3.5 * grid_step,
    screen.y + grid_step
  )
  suit.Label(
    "Now:",
    ui._create_label_options("left"),
    suit.layout:row(1.5 * grid_step, 0.75 * grid_step)
  )
  suit.Label(
    tostring(stats.current),
    ui._create_label_options("right"),
    suit.layout:col(grid_step, 0.75 * grid_step)
  )

  -- minimal stats
  suit.layout:reset(
    screen.x + screen.width - 3.5 * grid_step,
    screen.y + 1.75 * grid_step
  )
  suit.Label(
    "Min:",
    ui._create_label_options("left"),
    suit.layout:row(1.5 * grid_step, 0.75 * grid_step)
  )
  suit.Label(
    tostring(stats.minimal),
    ui._create_label_options("right"),
    suit.layout:col(grid_step, 0.75 * grid_step)
  )
end

function ui._update_buttons(screen)
  assert(typeutils.is_instance(screen, Rectangle))

  local grid_step = screen.height / 10
  suit.layout:reset(screen.x + grid_step, screen.y + grid_step)

  local reset_button = suit.Button("@", suit.layout:row(grid_step, grid_step))
  return UiUpdate:new(reset_button.hit)
end

function ui._create_label_options(align)
  assert(align == "left" or align == "right")

  return {
    color = {normal = {fg = {1, 1, 1}}},
    align = align,
    valign = "top",
  }
end

return ui
