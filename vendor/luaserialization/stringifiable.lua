-- luacheck: no max comment line length

--- ⚠️. This class is a mixin that adds the `__tostring()` metamethod. This metamethod calls the @{string.to_string|string.to_string()} function for the mix target class.
-- @classmod Stringifiable

local string_module = require("luaserialization.string")

local Stringifiable = {}

---
-- @treturn string
function Stringifiable:__tostring()
  return string_module.to_string(self)
end

return Stringifiable
