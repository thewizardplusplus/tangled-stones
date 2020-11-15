local suit = require("suit")

local ui = {}

function ui.update_labels(screen, stats)
  local grid_step = screen.height / 10

  -- current stats
  suit.layout:reset(screen.x + screen.width - 3.5 * grid_step, screen.y + grid_step / 2)
  suit.Label(
    "Now:",
    ui._create_label_options("left"),
    suit.layout:row(2 * grid_step, grid_step)
  )
  suit.Label(
    tostring(stats.current),
    ui._create_label_options("right"),
    suit.layout:col(grid_step, grid_step)
  )

  -- minimal stats
  suit.layout:reset(screen.x + screen.width - 3.5 * grid_step, screen.y + 1.5 * grid_step)
  suit.Label(
    "Min:",
    ui._create_label_options("left"),
    suit.layout:row(2 * grid_step, grid_step)
  )
  suit.Label(
    tostring(stats.minimal),
    ui._create_label_options("right"),
    suit.layout:col(grid_step, grid_step)
  )
end

function ui._create_label_options(align)
  return {
    color = {normal = {fg = {1, 1, 1}}},
    align = align,
    valign = "top",
  }
end

return ui
