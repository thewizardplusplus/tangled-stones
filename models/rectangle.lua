local middleclass = require("middleclass")

local Rectangle = middleclass("Rectangle")

function Rectangle:initialize(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
end

return Rectangle
