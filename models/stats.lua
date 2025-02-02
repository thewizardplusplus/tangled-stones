-- luacheck: no max comment line length

---
-- @classmod Stats

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")

---
-- @table instance
-- @tfield number current [0, ∞)
-- @tfield number minimal [0, ∞)

local Stats = middleclass("Stats")
Stats:include(Nameable)
Stats:include(Stringifiable)

---
-- @function new
-- @tparam number current [0, ∞)
-- @tparam number minimal [0, ∞)
-- @treturn Stats
function Stats:initialize(current, minimal)
  assertions.is_number(current)
  assertions.is_number(minimal)

  self.current = current
  self.minimal = minimal
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Stats:__data()
  return {
    current = self.current,
    minimal = self.minimal,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

return Stats
