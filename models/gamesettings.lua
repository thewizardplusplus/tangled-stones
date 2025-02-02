-- luacheck: no max comment line length

---
-- @classmod GameSettings

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")

---
-- @table instance
-- @tfield number side_count

local GameSettings = middleclass("GameSettings")
GameSettings:include(Nameable)
GameSettings:include(Stringifiable)

---
-- @function new
-- @tparam number side_count [0, ∞)
-- @treturn GameSettings
function GameSettings:initialize(side_count)
  assertions.is_number(side_count)

  self.side_count = side_count
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function GameSettings:__data()
  return {
    side_count = self.side_count,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

return GameSettings
