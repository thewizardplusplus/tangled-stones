-- luacheck: no max comment line length

---
-- @module utils

local assertions = require("luatypechecks.assertions")

local utils = {}

---
-- @tparam number value
-- @treturn -1|0|1 -1 for a negative value, 0 for zero, or 1 for a positive value
function utils.sign(value)
  assertions.is_number(value)

  if value < 0 then
    return -1
  elseif value > 0 then
    return 1
  end

  return 0
end

---
-- @tparam number value
-- @tparam[opt=0] int precision number of decimal places; negative values round
--   to places before the decimal point (e.g., `-2` rounds to hundreds)
-- @treturn number
function utils.round(value, precision)
  precision = precision or 0

  assertions.is_number(value)
  assertions.is_integer(precision)

  local value_sign = utils.sign(value)
  local factor = 10 ^ precision
  local scaled_value = value * factor

  -- compare the fractional part instead of adding 0.5 before truncation;
  -- adding it can round values just below a half up and change large integral
  -- floating-point values; see https://github.com/golang/go/issues/20100
  local rounded_value = value_sign >= 0
    and math.floor(scaled_value)
    or math.ceil(scaled_value)
  if math.abs(scaled_value - rounded_value) >= 0.5 then
    rounded_value = rounded_value + value_sign
  end

  local result = rounded_value / factor

  -- restore the integer subtype for integral results after float division
  local integer_result = math.floor(result)
  return integer_result == result and integer_result or result
end

---
-- @tparam number left_operand
-- @tparam number right_operand
-- @tparam[opt=1e-6] number epsilon
-- @treturn boolean
function utils.almost_equal(left_operand, right_operand, epsilon)
  epsilon = epsilon or 1e-6

  assertions.is_number(left_operand)
  assertions.is_number(right_operand)
  assertions.is_number(epsilon)

  return math.abs(left_operand - right_operand) <= epsilon
end

---
-- @tparam number value
-- @tparam number minimum
-- @tparam number maximum
-- @treturn number
function utils.clamp(value, minimum, maximum)
  assertions.is_number(value)
  assertions.is_number(minimum)
  assertions.is_number(maximum)

  if value < minimum then
    value = minimum
  elseif value > maximum then
    value = maximum
  end

  return value
end

---
-- @tparam number minimum
-- @tparam number maximum
-- @tparam number progress
-- @treturn number
function utils.lerp(minimum, maximum, progress)
  assertions.is_number(minimum)
  assertions.is_number(maximum)
  assertions.is_number(progress)

  return (maximum - minimum) * progress + minimum
end

---
-- @tparam number minimum
-- @tparam number maximum
-- @tparam number value
-- @treturn number
-- @raise error message
function utils.inverse_lerp(minimum, maximum, value)
  assertions.is_number(minimum)
  assertions.is_number(maximum)
  assertions.is_number(value)

  if minimum == maximum then
    error("`minimum` and `maximum` must be different")
  end

  return (value - minimum) / (maximum - minimum)
end

---
-- @tparam number value
-- @tparam number minimum
-- @tparam number maximum
-- @treturn number value in the half-open interval `[minimum, maximum)`
-- @raise error message
function utils.wrap(value, minimum, maximum)
  assertions.is_number(value)
  assertions.is_number(minimum)
  assertions.is_number(maximum)

  if minimum >= maximum then
    error("`minimum` must be less than `maximum`")
  end

  return (value - minimum) % (maximum - minimum) + minimum
end

---
-- @tparam number minimum
-- @tparam number maximum
-- @treturn number value in the half-open interval `[minimum, maximum)`
-- @raise error message
function utils.random_in_range(minimum, maximum)
  assertions.is_number(minimum)
  assertions.is_number(maximum)

  if minimum >= maximum then
    error("`minimum` must be less than `maximum`")
  end

  return utils.lerp(minimum, maximum, math.random())
end

return utils
