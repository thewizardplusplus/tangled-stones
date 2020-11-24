local function _is_positive_number(value)
  return type(value) == "number" and value >= 0
end

local function _set_title(config, title)
  assert(type(config) == "table")
  assert(type(title) == "string")

  config.window.title = title
  config.identity = string.lower(title)
end

local function _set_screen_width(config, width, aspect_ratio, prefix)
  assert(type(config) == "table")
  assert(_is_positive_number(width))
  assert(_is_positive_number(aspect_ratio))
  assert(type(prefix) == "string")

  config.window[prefix .. "width"] = width
  config.window[prefix .. "height"] = width / aspect_ratio
end

function love.conf(config)
  config.version = "11.3"

  config.window.resizable = true
  config.window.msaa = 8

  _set_title(config, "Tangled Stones")
  for _, prefix in ipairs({"", "min"}) do
    _set_screen_width(config, 640, 16 / 10, prefix)
  end
end
