-- luacheck: no max comment line length

---
-- A closed numeric range. Both endpoints belong to the range.
-- @classmod Range

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")
local utils = require("luamath.utils")

local Range = middleclass("Range")
Range:include(Nameable)
Range:include(Stringifiable)

---
-- @function schema
-- @static
-- @treturn tab JSON Schema for this class
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Range.static.schema()
  return {
    type = "object",
    required = {"min", "max"},
    properties = { min = { type = "number" }, max = { type = "number" } },
  }
end

---
-- @function from_options
-- @static
-- @tparam tab options constructor options conforming to the JSON Schema
--   returned by @{Range.schema|Range.schema()}
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
-- @treturn Range
function Range.static.from_options(options)
  assertions.is_table(options)

  return Range:new(options.min, options.max)
end

---
-- @function union
-- @static
-- @tparam Range,... ... one or more ranges
-- @treturn Range the smallest range containing all input ranges
-- @raise error message
function Range.static.union(...)
  local ranges = {...}

  assertions.is_sequence(ranges, checks.make_instance_checker(Range))

  if #ranges == 0 then
    error("at least one range required")
  end

  local range = ranges[1]
  local result = Range:new(range.min, range.max)

  for range_index = 2, #ranges do
    local range = ranges[range_index] -- luacheck: no redefined

    if range.min < result.min then
      result.min = range.min
    end

    if range.max > result.max then
      result.max = range.max
    end
  end

  return result
end

---
-- @function intersection
-- @static
-- @tparam Range,... ... one or more ranges
-- @treturn Range|nil the common closed interval of all input ranges, or nil if empty;
--   ranges touching at an endpoint produce a degenerate range
-- @raise error message
function Range.static.intersection(...)
  local ranges = {...}

  assertions.is_sequence(ranges, checks.make_instance_checker(Range))

  if #ranges == 0 then
    error("at least one range required")
  end

  local range = ranges[1]
  local result = Range:new(range.min, range.max)

  for range_index = 2, #ranges do
    local range = ranges[range_index] -- luacheck: no redefined

    if range.min > result.min then
      result.min = range.min
    end

    if range.max < result.max then
      result.max = range.max
    end
  end

  if not result:is_valid() then
    return nil
  end

  return result
end

---
-- @table instance
-- @tfield number min
-- @tfield number max

---
-- @function new
-- @tparam number min
-- @tparam number max
-- @treturn Range
-- @raise error message
function Range:initialize(min, max)
  assertions.is_number(min)
  assertions.is_number(max)

  self.min = min
  self.max = max

  if not self:is_valid() then
    error("`min` must be at most `max`")
  end
end

---
-- @treturn table table with instance fields
function Range:__data()
  return {
    min = self.min,
    max = self.max,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields

---
-- @tparam Range other
-- @treturn boolean
function Range:equals(other)
  if not checks.is_instance(other, Range) then
    return false
  end

  return self.min == other.min and self.max == other.max
end

---
-- @tparam Range left_operand
-- @tparam Range right_operand
-- @treturn boolean
function Range.__eq(left_operand, right_operand)
  if
    not checks.is_instance(left_operand, Range)
      or not checks.is_instance(right_operand, Range)
  then
    return false
  end

  return left_operand:equals(right_operand)
end

---
-- @tparam Range other
-- @tparam[opt=1e-6] number epsilon
-- @treturn boolean
function Range:almost_equals(other, epsilon)
  epsilon = epsilon or 1e-6

  assertions.is_number(epsilon)

  if not checks.is_instance(other, Range) then
    return false
  end

  return utils.almost_equal(self.min, other.min, epsilon)
    and utils.almost_equal(self.max, other.max, epsilon)
end

---
-- @treturn boolean whether `min` is at most `max`
function Range:is_valid()
  return self.min <= self.max
end

---
-- @treturn boolean whether the range has zero length
function Range:is_degenerate()
  return self.min == self.max
end

---
-- @tparam[opt=1e-6] number epsilon
-- @treturn boolean whether the range has almost zero length
function Range:is_almost_degenerate(epsilon)
  epsilon = epsilon or 1e-6

  assertions.is_number(epsilon)

  return utils.almost_equal(self.min, self.max, epsilon)
end

---
-- @treturn number
function Range:length()
  return self.max - self.min
end

---
-- @function __len
-- @treturn number
Range.__len = Range.length

---
-- @treturn number
function Range:center()
  return (self.min + self.max) / 2
end

---
-- @tparam Range other
-- @treturn boolean whether the intersection has positive length;
--   contact only at an endpoint does not count
function Range:overlaps(other)
  assertions.is_instance(other, Range)

  local intersection_min = math.max(self.min, other.min)
  local intersection_max = math.min(self.max, other.max)
  return intersection_min < intersection_max
end

---
-- @tparam number|Range value
-- @treturn boolean whether the closed range contains the value; endpoints are included
function Range:contains(value)
  local is_value_number = checks.is_number(value)
  local is_value_range = checks.is_instance(value, Range)
  assertions.is_true(is_value_number or is_value_range)

  if is_value_number then
    return value >= self.min and value <= self.max
  end

  if is_value_range then
    return value.min >= self.min and value.max <= self.max
  end
end

---
-- @tparam number value
-- @treturn number
function Range:clamp(value)
  assertions.is_number(value)

  return utils.clamp(value, self.min, self.max)
end

---
-- @tparam number progress
-- @treturn number
function Range:lerp(progress)
  assertions.is_number(progress)

  return utils.lerp(self.min, self.max, progress)
end

---
-- @tparam number value
-- @treturn number
-- @raise error message
function Range:inverse_lerp(value)
  assertions.is_number(value)

  return utils.inverse_lerp(self.min, self.max, value)
end

---
-- @tparam number value
-- @treturn number value in the half-open interval `[min, max)`
-- @raise error message
function Range:wrap(value)
  assertions.is_number(value)

  return utils.wrap(value, self.min, self.max)
end

---
-- @treturn number value in the half-open interval `[min, max)`
-- @raise error message
function Range:random()
  return utils.random_in_range(self.min, self.max)
end

---
-- @tparam number delta
-- @treturn Range
function Range:translate(delta)
  assertions.is_number(delta)

  return Range:new(self.min + delta, self.max + delta)
end

---
-- @tparam Range left_operand
-- @tparam number right_operand
-- @treturn Range
function Range.__add(left_operand, right_operand)
  assertions.is_instance(left_operand, Range)
  assertions.is_number(right_operand)

  return left_operand:translate(right_operand)
end

---
-- @tparam Range left_operand
-- @tparam number right_operand
-- @treturn Range
function Range.__sub(left_operand, right_operand)
  assertions.is_instance(left_operand, Range)
  assertions.is_number(right_operand)

  return left_operand:translate(-right_operand)
end

---
-- ⚠️. Expand the range symmetrically.
-- @tparam number delta
-- @treturn Range
-- @raise error message
function Range:expand(delta)
  assertions.is_number(delta)

  return Range:new(self.min - delta, self.max + delta)
end

---
-- ⚠️. Scale the range around its center.
-- @tparam number factor non-negative scale factor
-- @treturn Range
-- @raise error message
function Range:scale(factor)
  assertions.is_number(factor)

  if factor < 0 then
    error("`factor` must be non-negative")
  end

  local center = self:center()
  local scaled_half_length = self:length() / 2 * factor
  return Range:new(center - scaled_half_length, center + scaled_half_length)
end

return Range
