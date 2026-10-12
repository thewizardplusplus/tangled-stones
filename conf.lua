local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local assertions = require("luatypechecks.assertions")
local Size = require("luamath.models.size")

local _SCREEN_WIDTH = 640
local _SCREEN_ASPECT_RATIO = 16 / 10

local function _set_title(config, title)
  assertions.is_table(config)
  assertions.is_string(title)

  config.window.title = title
  config.identity = string.lower(title)
end

local function _set_screen_size(config, size, prefix)
  assertions.is_table(config)
  assertions.is_instance(size, Size)
  assertions.is_string(prefix)

  config.window[prefix .. "width"] = size.width
  config.window[prefix .. "height"] = size.height
end

function love.conf(config)
  assertions.is_table(config)

  config.version = "11.3"

  config.window.resizable = true
  config.window.msaa = 8

  local screen_size =
    Size:new(_SCREEN_WIDTH, _SCREEN_WIDTH / _SCREEN_ASPECT_RATIO)
  _set_title(config, "Tangled Stones")
  for _, prefix in ipairs({"", "min"}) do
    _set_screen_size(config, screen_size, prefix)
  end
end
