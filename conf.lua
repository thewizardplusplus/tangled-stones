local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local assertions = require("luatypechecks.assertions")

local function _set_title(config, title)
  assertions.is_table(config)
  assertions.is_string(title)

  config.window.title = title
  config.identity = string.lower(title)
end

local function _set_screen_width(config, width, aspect_ratio, prefix)
  assertions.is_table(config)
  assertions.is_number(width)
  assertions.is_number(aspect_ratio)
  assertions.is_string(prefix)

  config.window[prefix .. "width"] = width
  config.window[prefix .. "height"] = width / aspect_ratio
end

function love.conf(config)
  assertions.is_table(config)

  config.version = "11.3"

  config.window.resizable = true
  config.window.msaa = 8

  _set_title(config, "Tangled Stones")
  for _, prefix in ipairs({"", "min"}) do
    _set_screen_width(config, 640, 16 / 10, prefix)
  end
end
