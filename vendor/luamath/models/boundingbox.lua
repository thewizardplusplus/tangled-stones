-- luacheck: no max comment line length

---
-- An axis-aligned bounding box with closed boundaries.
-- Points on its edges and corners belong to the box.
-- @classmod BoundingBox

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")
local Vector2D = require("luamath.vector2d")
local Size = require("luamath.models.size")
local Range = require("luamath.models.range")
local utils = require("luamath.utils")

local BoundingBox = middleclass("BoundingBox")
BoundingBox:include(Nameable)
BoundingBox:include(Stringifiable)

---
-- @function schema
-- @static
-- @treturn tab JSON Schema for this class
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function BoundingBox.static.schema()
  return {
    type = "object",
    required = {"min", "max"},
    properties = { min = Vector2D.schema(), max = Vector2D.schema() },
  }
end

---
-- @function from_options
-- @static
-- @tparam tab options constructor options conforming to the JSON Schema
--   returned by @{BoundingBox.schema|BoundingBox.schema()}
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
-- @treturn BoundingBox
function BoundingBox.static.from_options(options)
  assertions.is_table(options)

  return BoundingBox:new(options.min, options.max)
end

---
-- @function from_position_and_size
-- @static
-- @tparam Vector2D position
-- @tparam Size size
-- @treturn BoundingBox
-- @raise error message
function BoundingBox.static.from_position_and_size(position, size)
  assertions.is_instance(position, Vector2D)
  assertions.is_instance(size, Size)

  return BoundingBox:new(position, position + size)
end

---
-- @function from_ranges
-- @static
-- @tparam Range x_range horizontal range
-- @tparam Range y_range vertical range
-- @treturn BoundingBox
function BoundingBox.static.from_ranges(x_range, y_range)
  assertions.is_instance(x_range, Range)
  assertions.is_instance(y_range, Range)

  return BoundingBox:new(
    Vector2D:new(x_range.min, y_range.min),
    Vector2D:new(x_range.max, y_range.max)
  )
end

---
-- @function union
-- @static
-- @tparam BoundingBox,... ... one or more boxes
-- @treturn BoundingBox the smallest box containing all input boxes
-- @raise error message
function BoundingBox.static.union(...)
  local boxes = {...}

  assertions.is_sequence(boxes, checks.make_instance_checker(BoundingBox))

  if #boxes == 0 then
    error("at least one bounding box required")
  end

  local box = boxes[1]
  local min = Vector2D:new(box.min.x, box.min.y)
  local max = Vector2D:new(box.max.x, box.max.y)
  local result = BoundingBox:new(min, max)

  for box_index = 2, #boxes do
    local box = boxes[box_index] -- luacheck: no redefined

    if box.min.x < result.min.x then
      result.min.x = box.min.x
    end
    if box.min.y < result.min.y then
      result.min.y = box.min.y
    end

    if box.max.x > result.max.x then
      result.max.x = box.max.x
    end
    if box.max.y > result.max.y then
      result.max.y = box.max.y
    end
  end

  return result
end

---
-- @function intersection
-- @static
-- @tparam BoundingBox,... ... one or more boxes
-- @treturn BoundingBox|nil the common closed region of all input boxes, or nil if empty
--   boxes touching at an edge or corner produce a degenerate box
-- @raise error message
function BoundingBox.static.intersection(...)
  local boxes = {...}

  assertions.is_sequence(boxes, checks.make_instance_checker(BoundingBox))

  if #boxes == 0 then
    error("at least one bounding box required")
  end

  local box = boxes[1]
  local min = Vector2D:new(box.min.x, box.min.y)
  local max = Vector2D:new(box.max.x, box.max.y)
  local result = BoundingBox:new(min, max)

  for box_index = 2, #boxes do
    local box = boxes[box_index] -- luacheck: no redefined

    if box.min.x > result.min.x then
      result.min.x = box.min.x
    end
    if box.min.y > result.min.y then
      result.min.y = box.min.y
    end

    if box.max.x < result.max.x then
      result.max.x = box.max.x
    end
    if box.max.y < result.max.y then
      result.max.y = box.max.y
    end
  end

  if not result:is_valid() then
    return nil
  end

  return result
end

---
-- @table instance
-- @tfield Vector2D min top-left corner
-- @tfield Vector2D max bottom-right corner

---
-- @function new
-- @tparam Vector2D min top-left corner
-- @tparam Vector2D max bottom-right corner
-- @treturn BoundingBox
-- @raise error message
function BoundingBox:initialize(min, max)
  assertions.is_instance(min, Vector2D)
  assertions.is_instance(max, Vector2D)

  self.min = Vector2D:new(min.x, min.y)
  self.max = Vector2D:new(max.x, max.y)

  if not self:is_valid() then
    error("`min` must be at most `max` on each axis")
  end
end

---
-- @treturn table table with instance fields
function BoundingBox:__data()
  return {
    min = self.min,
    max = self.max,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields

---
-- @tparam BoundingBox other
-- @treturn boolean
function BoundingBox:equals(other)
  if not checks.is_instance(other, BoundingBox) then
    return false
  end

  return self.min == other.min and self.max == other.max
end

---
-- @tparam BoundingBox left_operand
-- @tparam BoundingBox right_operand
-- @treturn boolean
function BoundingBox.__eq(left_operand, right_operand)
  if
    not checks.is_instance(left_operand, BoundingBox)
      or not checks.is_instance(right_operand, BoundingBox)
  then
    return false
  end

  return left_operand:equals(right_operand)
end

---
-- @tparam BoundingBox other
-- @tparam[opt=1e-6] number epsilon
-- @treturn boolean
function BoundingBox:almost_equals(other, epsilon)
  epsilon = epsilon or 1e-6

  assertions.is_number(epsilon)

  if not checks.is_instance(other, BoundingBox) then
    return false
  end

  return self.min:almost_equals(other.min, epsilon)
    and self.max:almost_equals(other.max, epsilon)
end

---
-- @treturn boolean whether `min` is at most `max` on each axis
function BoundingBox:is_valid()
  return self.min.x <= self.max.x and self.min.y <= self.max.y
end

---
-- @tparam[opt] "x"|"y" axis axis to check;
--   when omitted, checks whether either axis is degenerate
-- @treturn boolean whether the selected axis, or either axis, has zero length
-- @raise error message
function BoundingBox:is_degenerate(axis)
  assertions.is_enumeration_or_nil(axis, {"x", "y"})

  if axis == "x" then
    return self.min.x == self.max.x
  elseif axis == "y" then
    return self.min.y == self.max.y
  elseif axis == nil then
    return self:is_degenerate("x") or self:is_degenerate("y")
  end
end

---
-- @tparam[opt=1e-6] number epsilon
-- @tparam[optchain] "x"|"y" axis axis to check;
--   when omitted, checks whether either axis is almost degenerate
-- @treturn boolean whether the selected axis, or either axis, has almost zero length
-- @raise error message
function BoundingBox:is_almost_degenerate(epsilon, axis)
  epsilon = epsilon or 1e-6

  assertions.is_number(epsilon)
  assertions.is_enumeration_or_nil(axis, {"x", "y"})

  if axis == "x" then
    return utils.almost_equal(self.min.x, self.max.x, epsilon)
  elseif axis == "y" then
    return utils.almost_equal(self.min.y, self.max.y, epsilon)
  elseif axis == nil then
    return self:is_almost_degenerate(epsilon, "x")
      or self:is_almost_degenerate(epsilon, "y")
  end
end

---
-- @treturn boolean whether the box is degenerate on both axes
function BoundingBox:is_point()
  return self:is_degenerate("x") and self:is_degenerate("y")
end

---
-- @tparam[opt=1e-6] number epsilon
-- @treturn boolean whether the box is almost degenerate on both axes
function BoundingBox:is_almost_point(epsilon)
  epsilon = epsilon or 1e-6

  assertions.is_number(epsilon)

  return self:is_almost_degenerate(epsilon, "x")
    and self:is_almost_degenerate(epsilon, "y")
end

---
-- @treturn Vector2D alias for `min`
function BoundingBox:position()
  return self.min
end

---
-- @treturn Size width and height of the box
function BoundingBox:size()
  local size_vector = self.max - self.min
  return Size:new(size_vector.x, size_vector.y)
end

---
-- @treturn Range horizontal range
function BoundingBox:x_range()
  return Range:new(self.min.x, self.max.x)
end

---
-- @treturn Range vertical range
function BoundingBox:y_range()
  return Range:new(self.min.y, self.max.y)
end

---
-- @treturn Vector2D center of the box
function BoundingBox:center()
  return (self.min + self.max) / 2
end

---
-- @treturn Vector2D top-left corner; alias for `min`
function BoundingBox:top_left()
  return self.min
end

---
-- @treturn Vector2D top-right corner
function BoundingBox:top_right()
  return Vector2D:new(self.max.x, self.min.y)
end

---
-- @treturn Vector2D bottom-left corner
function BoundingBox:bottom_left()
  return Vector2D:new(self.min.x, self.max.y)
end

---
-- @treturn Vector2D bottom-right corner; alias for `max`
function BoundingBox:bottom_right()
  return self.max
end

---
-- @tparam BoundingBox other
-- @treturn boolean whether the intersection has positive area; contact only at
--   edges or corners does not count
function BoundingBox:overlaps(other)
  assertions.is_instance(other, BoundingBox)

  local intersection_min_x = math.max(self.min.x, other.min.x)
  local intersection_min_y = math.max(self.min.y, other.min.y)
  local intersection_max_x = math.min(self.max.x, other.max.x)
  local intersection_max_y = math.min(self.max.y, other.max.y)
  return intersection_min_x < intersection_max_x
    and intersection_min_y < intersection_max_y
end

---
-- @tparam Vector2D|BoundingBox value
-- @treturn boolean whether the closed box contains the value;
--   points and box boundaries are included
function BoundingBox:contains(value)
  local is_value_vector_2d = checks.is_instance(value, Vector2D)
  local is_value_bounding_box = checks.is_instance(value, BoundingBox)
  assertions.is_true(is_value_vector_2d or is_value_bounding_box)

  if is_value_vector_2d then
    return value.x >= self.min.x and value.x <= self.max.x
      and value.y >= self.min.y and value.y <= self.max.y
  end

  if is_value_bounding_box then
    return self.min.x <= value.min.x and self.max.x >= value.max.x
      and self.min.y <= value.min.y and self.max.y >= value.max.y
  end
end

---
-- @tparam Vector2D value
-- @treturn Vector2D value clamped independently on each axis
function BoundingBox:clamp(value)
  assertions.is_instance(value, Vector2D)

  return Vector2D:new(
    self:x_range():clamp(value.x),
    self:y_range():clamp(value.y)
  )
end

---
-- @tparam Vector2D progress per-axis interpolation progress
-- @treturn Vector2D
function BoundingBox:lerp(progress)
  assertions.is_instance(progress, Vector2D)

  return Vector2D:new(
    self:x_range():lerp(progress.x),
    self:y_range():lerp(progress.y)
  )
end

---
-- @tparam Vector2D value
-- @treturn Vector2D per-axis interpolation progress
-- @raise error message if either axis is degenerate
function BoundingBox:inverse_lerp(value)
  assertions.is_instance(value, Vector2D)

  if self:is_degenerate() then
    error("cannot inverse lerp a bounding box with a degenerate axis")
  end

  return Vector2D:new(
    self:x_range():inverse_lerp(value.x),
    self:y_range():inverse_lerp(value.y)
  )
end

---
-- @tparam Vector2D value
-- @treturn Vector2D value wrapped independently into the half-open intervals
--   `[min.x, max.x)` and `[min.y, max.y)`
-- @raise error message if either axis is degenerate
function BoundingBox:wrap(value)
  assertions.is_instance(value, Vector2D)

  if self:is_degenerate() then
    error("cannot wrap in a bounding box with a degenerate axis")
  end

  return Vector2D:new(
    self:x_range():wrap(value.x),
    self:y_range():wrap(value.y)
  )
end

---
-- @treturn Vector2D random value in the half-open intervals
--   `[min.x, max.x)` and `[min.y, max.y)`
-- @raise error message if either axis is degenerate
function BoundingBox:random()
  if self:is_degenerate() then
    local message =
      "cannot generate a random point in a bounding box with a degenerate axis"
    error(message)
  end

  return Vector2D:new(self:x_range():random(), self:y_range():random())
end

---
-- @tparam Vector2D delta
-- @treturn BoundingBox
function BoundingBox:translate(delta)
  assertions.is_instance(delta, Vector2D)

  return BoundingBox:new(self.min + delta, self.max + delta)
end

---
-- @tparam BoundingBox left_operand
-- @tparam Vector2D right_operand
-- @treturn BoundingBox
function BoundingBox.__add(left_operand, right_operand)
  assertions.is_instance(left_operand, BoundingBox)
  assertions.is_instance(right_operand, Vector2D)

  return left_operand:translate(right_operand)
end

---
-- @tparam BoundingBox left_operand
-- @tparam Vector2D right_operand
-- @treturn BoundingBox
function BoundingBox.__sub(left_operand, right_operand)
  assertions.is_instance(left_operand, BoundingBox)
  assertions.is_instance(right_operand, Vector2D)

  return left_operand:translate(-right_operand)
end

---
-- ⚠️. Expand the box symmetrically by per-axis amounts.
-- @tparam number|Vector2D delta uniform or per-axis amount
-- @treturn BoundingBox
-- @raise error message
function BoundingBox:expand(delta)
  local is_delta_number = checks.is_number(delta)
  local is_delta_vector_2d = checks.is_instance(delta, Vector2D)
  assertions.is_true(is_delta_number or is_delta_vector_2d)

  if is_delta_number then
    delta = Vector2D:new(delta, delta)
  end

  return BoundingBox:new(self.min - delta, self.max + delta)
end

---
-- ⚠️. Scale the box around its center by per-axis factors.
-- @tparam number|Vector2D scale non-negative uniform or per-axis scale
-- @treturn BoundingBox
-- @raise error message
function BoundingBox:scale(scale)
  local is_scale_number = checks.is_number(scale)
  local is_scale_vector_2d = checks.is_instance(scale, Vector2D)
  assertions.is_true(is_scale_number or is_scale_vector_2d)

  if is_scale_number then
    if scale < 0 then
      error("`scale` must be non-negative")
    end

    scale = Vector2D:new(scale, scale)
  end

  if is_scale_vector_2d and (scale.x < 0 or scale.y < 0) then
    error("every component of `scale` must be non-negative")
  end

  local center = self:center()
  local scaled_half_size = (self:size() / 2) * scale
  return BoundingBox:new(center - scaled_half_size, center + scaled_half_size)
end

return BoundingBox
