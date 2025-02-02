-- luacheck: no max comment line length

---
-- @classmod UiUpdate

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")

---
-- @table instance
-- @tfield bool reset

local UiUpdate = middleclass("UiUpdate")
UiUpdate:include(Nameable)
UiUpdate:include(Stringifiable)

---
-- @function new
-- @tparam bool reset
-- @treturn UiUpdate
function UiUpdate:initialize(reset)
  assertions.is_boolean(reset)

  self.reset = reset
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function UiUpdate:__data()
  return {
    reset = self.reset,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

return UiUpdate
