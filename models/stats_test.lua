local luaunit = require("luaunit")
local Stats = require("models.stats")

-- luacheck: globals TestStats
TestStats = {}

function TestStats.test_tostring()
  local settings = Stats:new(42, 23)
  local text = tostring(settings)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{__name = \"Stats\",current = 42,minimal = 23}")
end
