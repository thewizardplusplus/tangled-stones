-- luacheck: no max comment line length

---
-- @classmod Vector2D

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")
local utils = require("luamath.utils")

local Vector2D = middleclass("Vector2D")
Vector2D:include(Nameable)
Vector2D:include(Stringifiable)

---
-- @function schema
-- @static
-- @treturn tab JSON Schema for this class
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Vector2D.static.schema()
  return {
    type = "object",
    required = {"x", "y"},
    properties = { x = { type = "number" }, y = { type = "number" } },
  }
end

---
-- @function from_options
-- @static
-- @tparam tab options constructor options conforming to the JSON Schema
--   returned by @{Vector2D.schema|Vector2D.schema()}
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
-- @treturn Vector2D
function Vector2D.static.from_options(options)
  assertions.is_table(options)

  return Vector2D:new(options.x, options.y)
end

---
-- @table class
-- @tfield Vector2D ZERO
-- @tfield Vector2D BASIS_X
-- @tfield Vector2D BASIS_Y

---
-- @table instance
-- @tfield number x
-- @tfield number y

---
-- @function new
-- @tparam number x
-- @tparam number y
-- @treturn Vector2D
function Vector2D:initialize(x, y)
  assertions.is_number(x)
  assertions.is_number(y)

  self.x = x
  self.y = y
end

---
-- @treturn table table with instance fields
function Vector2D:__data()
  return {
    x = self.x,
    y = self.y,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields

---
-- @tparam Vector2D other
-- @treturn boolean
function Vector2D:equals(other)
  if not checks.is_instance(other, Vector2D) then
    return false
  end

  return self.x == other.x and self.y == other.y
end

---
-- @tparam Vector2D left_operand
-- @tparam Vector2D right_operand
-- @treturn boolean
function Vector2D.__eq(left_operand, right_operand)
  if
    not checks.is_instance(left_operand, Vector2D)
      or not checks.is_instance(right_operand, Vector2D)
  then
    return false
  end

  return left_operand:equals(right_operand)
end

---
-- @tparam Vector2D other
-- @tparam[opt=1e-6] number epsilon
-- @treturn boolean
function Vector2D:almost_equals(other, epsilon)
  epsilon = epsilon or 1e-6

  assertions.is_number(epsilon)

  if not checks.is_instance(other, Vector2D) then
    return false
  end

  return utils.almost_equal(self.x, other.x, epsilon)
    and utils.almost_equal(self.y, other.y, epsilon)
end

---
-- @treturn number
function Vector2D:length_squared()
  return self.x * self.x + self.y * self.y
end

---
-- @treturn number
function Vector2D:length()
  return math.sqrt(self:length_squared())
end

---
-- @function __len
-- @treturn number
Vector2D.__len = Vector2D.length

---
-- @treturn Vector2D
-- @raise error message
function Vector2D:normalized()
  local length = self:length()
  if length == 0 then
    error("cannot normalize zero-length vector")
  end

  return self:div(length)
end

---
-- @tparam Vector2D other
-- @treturn Vector2D
function Vector2D:add(other)
  assertions.is_instance(other, Vector2D)

  return Vector2D:new(self.x + other.x, self.y + other.y)
end

---
-- @tparam Vector2D left_operand
-- @tparam Vector2D right_operand
-- @treturn Vector2D
function Vector2D.__add(left_operand, right_operand)
  assertions.is_instance(left_operand, Vector2D)
  assertions.is_instance(right_operand, Vector2D)

  return left_operand:add(right_operand)
end

---
-- @tparam Vector2D other
-- @treturn Vector2D
function Vector2D:sub(other)
  assertions.is_instance(other, Vector2D)

  return Vector2D:new(self.x - other.x, self.y - other.y)
end

---
-- @tparam Vector2D left_operand
-- @tparam Vector2D right_operand
-- @treturn Vector2D
function Vector2D.__sub(left_operand, right_operand)
  assertions.is_instance(left_operand, Vector2D)
  assertions.is_instance(right_operand, Vector2D)

  return left_operand:sub(right_operand)
end

---
-- @tparam number|Vector2D|Matrix3x3 value
-- @treturn Vector2D
function Vector2D:mul(value)
  -- import locally to avoid cyclic dependencies
  local Matrix3x3 = require("luamath.matrix3x3")

  local is_value_number = checks.is_number(value)
  local is_value_vector_2d = checks.is_instance(value, Vector2D)
  local is_value_matrix_3x3 = checks.is_instance(value, Matrix3x3)
  assertions.is_true(
    is_value_number
    or is_value_vector_2d
    or is_value_matrix_3x3
  )

  if is_value_number then
    return Vector2D:new(self.x * value, self.y * value)
  end

  if is_value_vector_2d then
    return Vector2D:new(self.x * value.x, self.y * value.y)
  end

  if is_value_matrix_3x3 then
    return value:mul(self)
  end
end

---
-- @tparam number|Vector2D|Matrix3x3 left_operand
-- @tparam number|Vector2D|Matrix3x3 right_operand
-- @treturn Vector2D
function Vector2D.__mul(left_operand, right_operand)
  -- import locally to avoid cyclic dependencies
  local Matrix3x3 = require("luamath.matrix3x3")

  local is_left_operand_number = checks.is_number(left_operand)
  local is_left_operand_vector_2d = checks.is_instance(left_operand, Vector2D)
  local is_left_operand_matrix_3x3 = checks.is_instance(left_operand, Matrix3x3)

  local is_right_operand_number = checks.is_number(right_operand)
  local is_right_operand_vector_2d = checks.is_instance(right_operand, Vector2D)
  local is_right_operand_matrix_3x3 =
    checks.is_instance(right_operand, Matrix3x3)

  assertions.is_true(
    (is_left_operand_vector_2d and (
      is_right_operand_number
      or is_right_operand_vector_2d
      or is_right_operand_matrix_3x3
    ))
    or (is_right_operand_vector_2d and (
      is_left_operand_number
      or is_left_operand_vector_2d
      or is_left_operand_matrix_3x3
    ))
  )

  if is_left_operand_vector_2d then
    return left_operand:mul(right_operand)
  end

  if is_right_operand_vector_2d then
    return right_operand:mul(left_operand)
  end
end

---
-- @treturn Vector2D
function Vector2D:neg()
  return self:mul(-1)
end

---
-- @function __unm
-- @treturn Vector2D
Vector2D.__unm = Vector2D.neg

---
-- @tparam Vector2D other
-- @treturn number
function Vector2D:dot(other)
  assertions.is_instance(other, Vector2D)

  return self.x * other.x + self.y * other.y
end

---
-- @tparam number|Vector2D value
-- @treturn Vector2D
-- @raise error message
function Vector2D:div(value)
  local is_value_number = checks.is_number(value)
  local is_value_vector_2d = checks.is_instance(value, Vector2D)
  assertions.is_true(is_value_number or is_value_vector_2d)

  if is_value_number then
    if value == 0 then
      error("division by zero")
    end

    return Vector2D:new(self.x / value, self.y / value)
  end

  if is_value_vector_2d then
    if value.x == 0 or value.y == 0 then
      error("component-wise division by zero")
    end

    return Vector2D:new(self.x / value.x, self.y / value.y)
  end
end

---
-- @tparam Vector2D left_operand
-- @tparam number|Vector2D right_operand
-- @treturn Vector2D
-- @raise error message
function Vector2D.__div(left_operand, right_operand)
  assertions.is_instance(left_operand, Vector2D)

  local is_right_operand_number = checks.is_number(right_operand)
  local is_right_operand_vector_2d = checks.is_instance(right_operand, Vector2D)
  assertions.is_true(is_right_operand_number or is_right_operand_vector_2d)

  return left_operand:div(right_operand)
end

-- we cannot declare the constants at the beginning since the method `initialize()` isn't defined there yet
Vector2D.static.ZERO = Vector2D:new(0, 0)
Vector2D.static.BASIS_X = Vector2D:new(1, 0)
Vector2D.static.BASIS_Y = Vector2D:new(0, 1)

return Vector2D
