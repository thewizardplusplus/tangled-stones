-- luacheck: no max comment line length

---
-- @classmod Size

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Vector2D = require("luamath.vector2d")

local Size = middleclass("Size", Vector2D)

---
-- @function schema
-- @static
-- @treturn tab JSON Schema for this class
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Size.static.schema()
  return {
    type = "object",
    required = {"width", "height"},
    properties = { width = { type = "number" }, height = { type = "number" } },
  }
end

---
-- @function from_options
-- @static
-- @tparam tab options constructor options conforming to the JSON Schema
--   returned by @{Size.schema|Size.schema()}
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
-- @treturn Size
function Size.static.from_options(options)
  assertions.is_table(options)

  return Size:new(options.width, options.height)
end

---
-- @table instance
-- @tfield number x
-- @tfield number y
-- @tfield number width (alias for `x`)
-- @tfield number height (alias for `y`)

---
-- @function new
-- @tparam number width
-- @tparam number height
-- @treturn Size
function Size:initialize(width, height)
  assertions.is_number(width)
  assertions.is_number(height)

  Vector2D.initialize(self, width, height)
end

---
-- ⚠️. Implements getters for the aliases `width` and `height`.
-- @tparam string key
-- @return any
function Size:__index(key)
  assertions.is_string(key)

  if key == "width" then
    return self.x
  elseif key == "height" then
    return self.y
  else
    return nil
  end
end

---
-- ⚠️. Implements setters for the aliases `width` and `height`.
-- @tparam string key
-- @tparam any value
function Size:__newindex(key, value)
  assertions.is_string(key)

  if key == "width" then
    self.x = value
  elseif key == "height" then
    self.y = value
  else
    rawset(self, key, value)
  end
end

---
-- @treturn table table with instance fields
function Size:__data()
  return {
    width = self.width,
    height = self.height,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields

---
-- @function equals
-- @tparam Vector2D other
-- @treturn boolean

---
-- @function __eq
-- @tparam Vector2D left_operand
-- @tparam Vector2D right_operand
-- @treturn boolean

---
-- @function almost_equals
-- @tparam Vector2D other
-- @tparam[opt=1e-6] number epsilon
-- @treturn boolean

---
-- @function length_squared
-- @treturn number

---
-- @function length
-- @treturn number

---
-- @function __len
-- @treturn number

---
-- @treturn Size
-- @raise error message
function Size:normalized()
  local result = Vector2D.normalized(self)
  return Size:new(result.x, result.y)
end

---
-- @tparam Vector2D other
-- @treturn Size
function Size:add(other)
  local result = Vector2D.add(self, other)
  return Size:new(result.x, result.y)
end

---
-- @tparam Vector2D left_operand
-- @tparam Vector2D right_operand
-- @treturn Size
function Size.__add(left_operand, right_operand)
  local result = Vector2D.__add(left_operand, right_operand)
  return Size:new(result.x, result.y)
end

---
-- @tparam Vector2D other
-- @treturn Size
function Size:sub(other)
  local result = Vector2D.sub(self, other)
  return Size:new(result.x, result.y)
end

---
-- @tparam Vector2D left_operand
-- @tparam Vector2D right_operand
-- @treturn Size
function Size.__sub(left_operand, right_operand)
  local result = Vector2D.__sub(left_operand, right_operand)
  return Size:new(result.x, result.y)
end

---
-- @tparam number|Vector2D|Matrix3x3 value
-- @treturn Size
function Size:mul(value)
  local result = Vector2D.mul(self, value)
  return Size:new(result.x, result.y)
end

---
-- @tparam number|Vector2D|Matrix3x3 left_operand
-- @tparam number|Vector2D|Matrix3x3 right_operand
-- @treturn Size
function Size.__mul(left_operand, right_operand)
  local result = Vector2D.__mul(left_operand, right_operand)
  return Size:new(result.x, result.y)
end

---
-- @treturn Size
function Size:neg()
  local result = Vector2D.neg(self)
  return Size:new(result.x, result.y)
end

---
-- @treturn Size
function Size:__unm()
  local result = Vector2D.__unm(self)
  return Size:new(result.x, result.y)
end

---
-- @function dot
-- @tparam Vector2D other
-- @treturn number

---
-- @tparam number|Vector2D value
-- @treturn Size
-- @raise error message
function Size:div(value)
  local result = Vector2D.div(self, value)
  return Size:new(result.x, result.y)
end

---
-- @tparam Vector2D left_operand
-- @tparam number|Vector2D right_operand
-- @treturn Size
-- @raise error message
function Size.__div(left_operand, right_operand)
  local result = Vector2D.__div(left_operand, right_operand)
  return Size:new(result.x, result.y)
end

return Size
