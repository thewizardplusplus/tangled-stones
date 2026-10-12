---
-- @module window

local Vector2D = require("luamath.vector2d")
local Size = require("luamath.models.size")
local BoundingBox = require("luamath.models.boundingbox")

local window = {}

---
-- @treturn bool always true
-- @error error message
function window.enter_fullscreen()
  local is_mobile_os = table.find({"Android", "iOS"}, love.system.getOS())
  if not is_mobile_os then
    return true
  end

  local ok = love.window.setFullscreen(true, "desktop")
  if not ok then
    return nil, "unable to enter fullscreen"
  end

  return true
end

---
-- @treturn BoundingBox
function window.create_screen()
  local x, y, width, height = love.window.getSafeArea()
  return BoundingBox.from_position_and_size(
    Vector2D:new(x, y),
    Size:new(width, height)
  )
end

return window
