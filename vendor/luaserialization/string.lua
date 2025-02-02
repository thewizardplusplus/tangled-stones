-- luacheck: no max comment line length

---
-- @module string

local data_module = require("luaserialization.data")
local inspect = require("inspect")

local string = {}

--- ⚠️. This function gets the value data with the @{data.to_data|data.to_data()} function. Then the function transforms this data into a string representation with library [inspect.lua](https://github.com/kikito/inspect.lua).
-- @tparam any value
-- @treturn string
function string.to_string(value)
  local data = data_module.to_data(value)
  return inspect(data, { newline = "", indent = "" })
end

return string
