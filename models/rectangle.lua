---
-- @classmod Rectangle

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")

---
-- @table instance
-- @tfield number x [0, ∞)
-- @tfield number y [0, ∞)
-- @tfield number width [0, ∞)
-- @tfield number height [0, ∞)

local Rectangle = middleclass("Rectangle")

---
-- @function new
-- @tparam number x [0, ∞)
-- @tparam number y [0, ∞)
-- @tparam number width [0, ∞)
-- @tparam number height [0, ∞)
-- @treturn Rectangle
function Rectangle:initialize(x, y, width, height)
  assertions.is_number(x)
  assertions.is_number(y)
  assertions.is_number(width)
  assertions.is_number(height)

  self.x = x
  self.y = y
  self.width = width
  self.height = height
end

return Rectangle
