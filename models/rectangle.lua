local middleclass = require("middleclass")
local typeutils = require("typeutils")

local Rectangle = middleclass("Rectangle")

function Rectangle:initialize(x, y, width, height)
  assert(typeutils.is_number_with_limits(x, 0))
  assert(typeutils.is_number_with_limits(y, 0))
  assert(typeutils.is_number_with_limits(width, 0))
  assert(typeutils.is_number_with_limits(height, 0))

  self.x = x
  self.y = y
  self.width = width
  self.height = height
end

return Rectangle
