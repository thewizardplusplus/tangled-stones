local middleclass = require("middleclass")
local typeutils = require("typeutils")

local Rectangle = middleclass("Rectangle")

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
