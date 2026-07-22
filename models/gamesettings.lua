-- luacheck: no max comment line length

---
-- @classmod GameSettings

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")

---
-- @table instance
-- @tfield int side_count [1, ∞)
-- @tfield bool auto_increment_side_count

local GameSettings = middleclass("GameSettings")
GameSettings:include(Nameable)
GameSettings:include(Stringifiable)

---
-- @table class
-- @tfield int MAX_SIDE_COUNT
-- @static
GameSettings.static.MAX_SIDE_COUNT = 20

---
-- @function schema
-- @static
-- @treturn tab JSON Schema for this class
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function GameSettings.static.schema()
  return {
    type = "object",
    required = {"side_count", "auto_increment_side_count"},
    properties = {
      side_count = {
        type = "number",
        minimum = 1,
        maximum = GameSettings.MAX_SIDE_COUNT,
        multipleOf = 1,
      },
      auto_increment_side_count = { type = "boolean" },
    },
  }
end

---
-- @function from_options
-- @static
-- @tparam tab options constructor options conforming to the JSON Schema
--   returned by @{GameSettings.schema|GameSettings.schema()}
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
-- @treturn GameSettings
function GameSettings.static.from_options(options)
  assertions.is_table(options)

  return GameSettings:new(options.side_count, options.auto_increment_side_count)
end

---
-- @function new
-- @tparam int side_count [1, ∞)
-- @tparam bool auto_increment_side_count
-- @treturn GameSettings
function GameSettings:initialize(side_count, auto_increment_side_count)
  assertions.is_integer(side_count)
  assertions.is_boolean(auto_increment_side_count)

  self.side_count = side_count
  self.auto_increment_side_count = auto_increment_side_count
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function GameSettings:__data()
  return {
    side_count = self.side_count,
    auto_increment_side_count = self.auto_increment_side_count,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

---
-- @treturn bool whether the side count was increased
function GameSettings:increment_side_count()
  if
    not self.auto_increment_side_count
      or self.side_count >= GameSettings.MAX_SIDE_COUNT
  then
    return false
  end

  self.side_count = self.side_count + 1
  return true
end

return GameSettings
