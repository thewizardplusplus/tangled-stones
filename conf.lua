local function set_title(config, title)
  config.window.title = title
  config.identity = string.lower(title)
end

local function set_screen_width(config, width, aspect_ratio, prefix)
  config.window[prefix .. "width"] = width
  config.window[prefix .. "height"] = width / aspect_ratio
end

function love.conf(config)
  config.version = "11.3"

  config.window.resizable = true
  config.window.msaa = 8

  set_title(config, "Tangled Stones")
  for _, prefix in ipairs({"", "min"}) do
    set_screen_width(config, 640, 16 / 10, prefix)
  end
end
