local ui = {}

function ui.create_label_options(align)
  return {
    color = {normal = {fg = {1, 1, 1}}},
    align = align,
    valign = "top",
  }
end

return ui
