-- luacheck: no max comment line length

---
-- @classmod Matrix3x3

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")
local Vector2D = require("luamath.vector2d")
local utils = require("luamath.utils")

local Matrix3x3 = middleclass("Matrix3x3")
Matrix3x3:include(Nameable)
Matrix3x3:include(Stringifiable)

---
-- @function schema
-- @static
-- @treturn tab JSON Schema for this class
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Matrix3x3.static.schema()
  return {
    type = "object",
    required = {"elements"},
    properties = {
      elements = {
        type = "array",
        minItems = 3,
        maxItems = 3,
        items = {
          type = "array",
          minItems = 3,
          maxItems = 3,
          items = { type = "number" },
        },
      },
    },
  }
end

---
-- @function from_options
-- @static
-- @tparam tab options constructor options conforming to the JSON Schema
--   returned by @{Matrix3x3.schema|Matrix3x3.schema()}
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
-- @treturn Matrix3x3
function Matrix3x3.static.from_options(options)
  assertions.is_table(options)

  return Matrix3x3:new(options.elements)
end

---
-- @table class
-- @tfield Matrix3x3 ZERO
-- @tfield Matrix3x3 IDENTITY

---
-- @function translate
-- @static
-- @tparam Vector2D delta
-- @treturn Matrix3x3
function Matrix3x3.static.translate(delta)
  assertions.is_instance(delta, Vector2D)

  return Matrix3x3:new({
    {1, 0, delta.x},
    {0, 1, delta.y},
    {0, 0, 1},
  })
end

---
-- @function rotate
-- @static
-- @tparam number angle in radians
-- @treturn Matrix3x3
function Matrix3x3.static.rotate(angle)
  assertions.is_number(angle)

  local angle_cos = math.cos(angle)
  local angle_sin = math.sin(angle)

  return Matrix3x3:new({
    {angle_cos, -angle_sin, 0},
    {angle_sin, angle_cos, 0},
    {0, 0, 1},
  })
end

---
-- @function scale
-- @static
-- @tparam number|Vector2D scale uniform or per-axis scale
-- @treturn Matrix3x3
function Matrix3x3.static.scale(scale)
  local is_scale_number = checks.is_number(scale)
  local is_scale_vector_2d = checks.is_instance(scale, Vector2D)
  assertions.is_true(is_scale_number or is_scale_vector_2d)

  if is_scale_number then
    return Matrix3x3:new({
      {scale, 0, 0},
      {0, scale, 0},
      {0, 0, 1},
    })
  end

  if is_scale_vector_2d then
    return Matrix3x3:new({
      {scale.x, 0, 0},
      {0, scale.y, 0},
      {0, 0, 1},
    })
  end
end

---
-- ⚠️. Creates a shear (skew) transformation, which slants a shape along one
-- or both axes by shifting each coordinate in proportion to the other:
-- `x' = x + shear.x * y`, `y' = y + shear.y * x`.
-- @function shear
-- @static
-- @tparam Vector2D shear per-axis shear factors
-- @treturn Matrix3x3
function Matrix3x3.static.shear(shear)
  assertions.is_instance(shear, Vector2D)

  return Matrix3x3:new({
    {1, shear.x, 0},
    {shear.y, 1, 0},
    {0, 0, 1},
  })
end

---
-- @table instance
-- @tfield number[3][3] elements

---
-- @function new
-- @tparam table elements 3×3 table of numbers
-- @treturn Matrix3x3
function Matrix3x3:initialize(elements)
  assertions.is_sequence(
    elements,
    checks.make_sequence_checker(checks.is_number)
  )

  if #elements ~= 3 then
    error("`elements` must contain exactly three rows")
  end

  self.elements = {}
  for index, row in ipairs(elements) do
    if #row ~= 3 then
      error("each row of `elements` must contain exactly three elements")
    end

    self.elements[index] = {row[1], row[2], row[3]}
  end
end

---
-- @treturn table table with instance fields
function Matrix3x3:__data()
  return {
    elements = self.elements,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields

---
-- @tparam Matrix3x3 other
-- @treturn boolean
function Matrix3x3:equals(other)
  if not checks.is_instance(other, Matrix3x3) then
    return false
  end

  for row = 1, 3 do
    for column = 1, 3 do
      if self.elements[row][column] ~= other.elements[row][column] then
        return false
      end
    end
  end

  return true
end

---
-- @tparam Matrix3x3 left_operand
-- @tparam Matrix3x3 right_operand
-- @treturn boolean
function Matrix3x3.__eq(left_operand, right_operand)
  if
    not checks.is_instance(left_operand, Matrix3x3)
      or not checks.is_instance(right_operand, Matrix3x3)
  then
    return false
  end

  return left_operand:equals(right_operand)
end

---
-- @tparam Matrix3x3 other
-- @tparam[opt=1e-6] number epsilon
-- @treturn boolean
function Matrix3x3:almost_equals(other, epsilon)
  epsilon = epsilon or 1e-6

  assertions.is_number(epsilon)

  if not checks.is_instance(other, Matrix3x3) then
    return false
  end

  for row = 1, 3 do
    for column = 1, 3 do
      if not utils.almost_equal(
        self.elements[row][column],
        other.elements[row][column],
        epsilon
      ) then
        return false
      end
    end
  end

  return true
end

---
-- @treturn Matrix3x3
-- @raise error message
function Matrix3x3:inverse()
  local element_11, element_12, element_13 =
    self.elements[1][1], self.elements[1][2], self.elements[1][3]
  local element_21, element_22, element_23 =
    self.elements[2][1], self.elements[2][2], self.elements[2][3]
  local element_31, element_32, element_33 =
    self.elements[3][1], self.elements[3][2], self.elements[3][3]

  -- first column of the adjugate matrix
  local adjugate_element_11 = element_22 * element_33 - element_23 * element_32
  local adjugate_element_21 = element_23 * element_31 - element_21 * element_33
  local adjugate_element_31 = element_21 * element_32 - element_22 * element_31

  local determinant =
    element_11 * adjugate_element_11
    + element_12 * adjugate_element_21
    + element_13 * adjugate_element_31
  if determinant == 0 then
    error("matrix is singular")
  end

  local adjugate = Matrix3x3:new({
    {
      adjugate_element_11,
      element_13 * element_32 - element_12 * element_33,
      element_12 * element_23 - element_13 * element_22,
    },
    {
      adjugate_element_21,
      element_11 * element_33 - element_13 * element_31,
      element_13 * element_21 - element_11 * element_23,
    },
    {
      adjugate_element_31,
      element_12 * element_31 - element_11 * element_32,
      element_11 * element_22 - element_12 * element_21,
    },
  })

  return adjugate:div(determinant)
end

---
-- @tparam Matrix3x3 other
-- @treturn Matrix3x3
function Matrix3x3:add(other)
  assertions.is_instance(other, Matrix3x3)

  local result = {}
  for row = 1, 3 do
    result[row] = {}

    for column = 1, 3 do
      result[row][column] =
        self.elements[row][column]
        + other.elements[row][column]
    end
  end

  return Matrix3x3:new(result)
end

---
-- @tparam Matrix3x3 left_operand
-- @tparam Matrix3x3 right_operand
-- @treturn Matrix3x3
function Matrix3x3.__add(left_operand, right_operand)
  assertions.is_instance(left_operand, Matrix3x3)
  assertions.is_instance(right_operand, Matrix3x3)

  return left_operand:add(right_operand)
end

---
-- @tparam Matrix3x3 other
-- @treturn Matrix3x3
function Matrix3x3:sub(other)
  assertions.is_instance(other, Matrix3x3)

  local result = {}
  for row = 1, 3 do
    result[row] = {}

    for column = 1, 3 do
      result[row][column] =
        self.elements[row][column]
        - other.elements[row][column]
    end
  end

  return Matrix3x3:new(result)
end

---
-- @tparam Matrix3x3 left_operand
-- @tparam Matrix3x3 right_operand
-- @treturn Matrix3x3
function Matrix3x3.__sub(left_operand, right_operand)
  assertions.is_instance(left_operand, Matrix3x3)
  assertions.is_instance(right_operand, Matrix3x3)

  return left_operand:sub(right_operand)
end

---
-- @tparam number|Vector2D|Matrix3x3 value
-- @treturn Vector2D|Matrix3x3
function Matrix3x3:mul(value)
  local is_value_number = checks.is_number(value)
  local is_value_vector_2d = checks.is_instance(value, Vector2D)
  local is_value_matrix_3x3 = checks.is_instance(value, Matrix3x3)
  assertions.is_true(
    is_value_number
    or is_value_vector_2d
    or is_value_matrix_3x3
  )

  if is_value_number then
    local result = {}
    for row = 1, 3 do
      result[row] = {}

      for column = 1, 3 do
        result[row][column] = self.elements[row][column] * value
      end
    end

    return Matrix3x3:new(result)
  end

  if is_value_vector_2d then
    local x =
      self.elements[1][1] * value.x
      + self.elements[1][2] * value.y
      + self.elements[1][3]
    local y =
      self.elements[2][1] * value.x
      + self.elements[2][2] * value.y
      + self.elements[2][3]
    return Vector2D:new(x, y)
  end

  if is_value_matrix_3x3 then
    local result = {}
    for row = 1, 3 do
      result[row] = {}

      for column = 1, 3 do
        result[row][column] = 0

        for k = 1, 3 do
          result[row][column] =
            result[row][column]
            + self.elements[row][k] * value.elements[k][column]
        end
      end
    end

    return Matrix3x3:new(result)
  end
end

---
-- @tparam number|Vector2D|Matrix3x3 left_operand
-- @tparam number|Vector2D|Matrix3x3 right_operand
-- @treturn Vector2D|Matrix3x3
function Matrix3x3.__mul(left_operand, right_operand)
  local is_left_operand_number = checks.is_number(left_operand)
  local is_left_operand_vector_2d = checks.is_instance(left_operand, Vector2D)
  local is_left_operand_matrix_3x3 = checks.is_instance(left_operand, Matrix3x3)

  local is_right_operand_number = checks.is_number(right_operand)
  local is_right_operand_vector_2d = checks.is_instance(right_operand, Vector2D)
  local is_right_operand_matrix_3x3 =
    checks.is_instance(right_operand, Matrix3x3)

  assertions.is_true(
    (is_left_operand_matrix_3x3 and (
      is_right_operand_number
      or is_right_operand_vector_2d
      or is_right_operand_matrix_3x3
    ))
    or (is_right_operand_matrix_3x3 and (
      is_left_operand_number
      or is_left_operand_vector_2d
      or is_left_operand_matrix_3x3
    ))
  )

  if is_left_operand_matrix_3x3 then
    return left_operand:mul(right_operand)
  end

  if is_right_operand_matrix_3x3 then
    return right_operand:mul(left_operand)
  end
end

---
-- @tparam number value
-- @treturn Matrix3x3
-- @raise error message
function Matrix3x3:div(value)
  assertions.is_number(value)

  if value == 0 then
    error("division by zero")
  end

  local result = {}
  for row = 1, 3 do
    result[row] = {}

    for column = 1, 3 do
      result[row][column] = self.elements[row][column] / value
    end
  end

  return Matrix3x3:new(result)
end

---
-- @tparam Matrix3x3 left_operand
-- @tparam number right_operand
-- @treturn Matrix3x3
-- @raise error message
function Matrix3x3.__div(left_operand, right_operand)
  assertions.is_instance(left_operand, Matrix3x3)
  assertions.is_number(right_operand)

  return left_operand:div(right_operand)
end

-- we cannot declare the constants at the beginning since the method `initialize()` isn't defined there yet
Matrix3x3.static.ZERO = Matrix3x3:new{
  {0, 0, 0},
  {0, 0, 0},
  {0, 0, 0}
}
Matrix3x3.static.IDENTITY = Matrix3x3:new{
  {1, 0, 0},
  {0, 1, 0},
  {0, 0, 1}
}

return Matrix3x3
