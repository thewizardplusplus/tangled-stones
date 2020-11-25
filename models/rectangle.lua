---
-- @classmod Rectangle

local middleclass = require("middleclass")
local typeutils = require("typeutils")

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
  assert(typeutils.is_positive_number(x))
  assert(typeutils.is_positive_number(y))
  assert(typeutils.is_positive_number(width))
  assert(typeutils.is_positive_number(height))

  self.x = x
  self.y = y
  self.width = width
  self.height = height
end

return Rectangle
