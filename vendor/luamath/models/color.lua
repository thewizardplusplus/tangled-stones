-- luacheck: no max comment line length

---
-- @classmod Color

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")
local utils = require("luamath.utils")

local function _is_valid_color_channel(value)
  return value >= 0 and value < math.huge
end

local function _is_normalized_channel(value)
  return _is_valid_color_channel(value) and value <= 1
end

local Color = middleclass("Color")
Color:include(Nameable)
Color:include(Stringifiable)

---
-- @function schema
-- @static
-- @treturn tab JSON Schema for this class
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Color.static.schema()
  local color_channel_schema = { type = "number", minimum = 0 }

  return {
    type = "object",
    required = {"red", "green", "blue"},
    properties = {
      red = color_channel_schema,
      green = color_channel_schema,
      blue = color_channel_schema,
      alpha = { type = "number", minimum = 0, maximum = 1 },
    },
  }
end

---
-- @function from_options
-- @static
-- @tparam tab options constructor options conforming to the JSON Schema
--   returned by @{Color.schema|Color.schema()}
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
-- @treturn Color
function Color.static.from_options(options)
  assertions.is_table(options)

  return Color:new(options.red, options.green, options.blue, options.alpha)
end

---
-- @function from_bytes
-- @static
-- @tparam int red
-- @tparam int green
-- @tparam int blue
-- @tparam[opt=255] int alpha
-- @treturn Color
-- @raise error message
function Color.static.from_bytes(red, green, blue, alpha)
  alpha = alpha or 255

  for name, value in pairs({
    red = red,
    green = green,
    blue = blue,
    alpha = alpha,
  }) do
    assertions.is_integer(value)

    if value < 0 or value > 255 then
      error(string.format(
        "byte channel %q must be an integer between 0 and 255",
        name
      ))
    end
  end

  return Color:new(red / 255, green / 255, blue / 255, alpha / 255)
end

---
-- @function from_hex
-- @static
-- @tparam string value hexadecimal color in `#RGB`, `#RGBA`, `#RRGGBB`, or `#RRGGBBAA` notation;
--   the leading `#` is optional
-- @treturn Color
-- @raise error message
function Color.static.from_hex(value)
  assertions.is_string(value)

  local hexadecimal = value:match("^#?(%x+)$")
  local length = hexadecimal and #hexadecimal or 0
  if length ~= 3 and length ~= 4 and length ~= 6 and length ~= 8 then
    local message =
      "hexadecimal color must use "
      .. "`#RGB`, `#RGBA`, `#RRGGBB`, or `#RRGGBBAA` notation"
    error(message)
  end

  if length == 3 or length == 4 then
    hexadecimal = hexadecimal:gsub("(%x)", "%1%1")
  end

  local red = tonumber(hexadecimal:sub(1, 2), 16)
  local green = tonumber(hexadecimal:sub(3, 4), 16)
  local blue = tonumber(hexadecimal:sub(5, 6), 16)
  local alpha = #hexadecimal == 8 and tonumber(hexadecimal:sub(7, 8), 16) or 255

  return Color.from_bytes(red, green, blue, alpha)
end

---
-- @table class
-- @tfield Color TRANSPARENT
-- @tfield Color BLACK
-- @tfield Color WHITE
-- @tfield Color RED
-- @tfield Color GREEN
-- @tfield Color BLUE

---
-- @table instance
-- @tfield number red finite non-negative red channel
-- @tfield number green finite non-negative green channel
-- @tfield number blue finite non-negative blue channel
-- @tfield number alpha normalized alpha channel

---
-- @function new
-- @tparam number red
-- @tparam number green
-- @tparam number blue
-- @tparam[opt=1] number alpha
-- @treturn Color
-- @raise error message
function Color:initialize(red, green, blue, alpha)
  alpha = alpha or 1

  assertions.is_number(red)
  assertions.is_number(green)
  assertions.is_number(blue)
  assertions.is_number(alpha)

  self.red = red
  self.green = green
  self.blue = blue
  self.alpha = alpha

  if not self:is_valid() then
    local message =
      "color channels must be finite non-negative numbers "
      .. "and alpha must be between 0 and 1"
    error(message)
  end
end

---
-- @treturn table table with instance fields
function Color:__data()
  return {
    red = self.red,
    green = self.green,
    blue = self.blue,
    alpha = self.alpha,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields

---
-- @tparam Color other
-- @treturn boolean
function Color:equals(other)
  if not checks.is_instance(other, Color) then
    return false
  end

  return self.red == other.red
    and self.green == other.green
    and self.blue == other.blue
    and self.alpha == other.alpha
end

---
-- @tparam Color left_operand
-- @tparam Color right_operand
-- @treturn boolean
function Color.__eq(left_operand, right_operand)
  if
    not checks.is_instance(left_operand, Color)
      or not checks.is_instance(right_operand, Color)
  then
    return false
  end

  return left_operand:equals(right_operand)
end

---
-- @tparam Color other
-- @tparam[opt=1e-6] number epsilon
-- @treturn boolean
function Color:almost_equals(other, epsilon)
  epsilon = epsilon or 1e-6

  assertions.is_number(epsilon)

  if not checks.is_instance(other, Color) then
    return false
  end

  return utils.almost_equal(self.red, other.red, epsilon)
    and utils.almost_equal(self.green, other.green, epsilon)
    and utils.almost_equal(self.blue, other.blue, epsilon)
    and utils.almost_equal(self.alpha, other.alpha, epsilon)
end

---
-- @treturn boolean whether the color channels are finite and non-negative
--   and the alpha channel is normalized
function Color:is_valid()
  return _is_valid_color_channel(self.red)
    and _is_valid_color_channel(self.green)
    and _is_valid_color_channel(self.blue)
    and _is_normalized_channel(self.alpha)
end

---
-- @tparam[opt=true] boolean include_alpha include the alpha channel
-- @treturn tab normalized channels in RGBA order
function Color:channels(include_alpha)
  assertions.is_boolean_or_nil(include_alpha)

  if include_alpha == nil then
    include_alpha = true
  end

  local channels = {self.red, self.green, self.blue}
  if include_alpha then
    channels[4] = self.alpha
  end

  return channels
end

---
-- @tparam "red"|"green"|"blue"|"alpha" channel
-- @treturn int channel converted to the byte range
-- @raise error message
function Color:byte_channel(channel)
  assertions.is_enumeration(channel, {"red", "green", "blue", "alpha"})

  local clamped_channel = utils.clamp(self[channel], 0, 1)
  return utils.round(clamped_channel * 255)
end

---
-- @tparam[opt=true] boolean include_alpha include the alpha channel
-- @treturn tab integer channels in RGBA order
function Color:byte_channels(include_alpha)
  assertions.is_boolean_or_nil(include_alpha)

  if include_alpha == nil then
    include_alpha = true
  end

  local channels = {
    self:byte_channel("red"),
    self:byte_channel("green"),
    self:byte_channel("blue"),
  }
  if include_alpha then
    channels[4] = self:byte_channel("alpha")
  end

  return channels
end

---
-- @tparam number alpha
-- @treturn Color
-- @raise error message
function Color:with_alpha(alpha)
  assertions.is_number(alpha)

  return Color:new(self.red, self.green, self.blue, alpha)
end

---
-- ⚠️. Return a copy with every channel clamped to the normalized range.
-- @treturn Color
function Color:clamped()
  return Color:new(
    utils.clamp(self.red, 0, 1),
    utils.clamp(self.green, 0, 1),
    utils.clamp(self.blue, 0, 1),
    utils.clamp(self.alpha, 0, 1)
  )
end

---
-- @tparam[opt] boolean include_alpha include the alpha channel;
--   by default, include it only when its byte value differs from 255
-- @treturn string hexadecimal color in `#RRGGBB` or `#RRGGBBAA` notation
function Color:to_hex(include_alpha)
  assertions.is_boolean_or_nil(include_alpha)

  local byte_channels = self:byte_channels()
  if include_alpha == nil then
    include_alpha = byte_channels[4] ~= 255
  end

  local result = string.format(
    "#%02x%02x%02x",
    byte_channels[1],
    byte_channels[2],
    byte_channels[3]
  )
  if include_alpha then
    result = result .. string.format("%02x", byte_channels[4])
  end

  return result
end

Color.static.TRANSPARENT = Color:new(0, 0, 0, 0)
Color.static.BLACK = Color:new(0, 0, 0)
Color.static.WHITE = Color:new(1, 1, 1)
Color.static.RED = Color:new(1, 0, 0)
Color.static.GREEN = Color:new(0, 1, 0)
Color.static.BLUE = Color:new(0, 0, 1)

return Color
