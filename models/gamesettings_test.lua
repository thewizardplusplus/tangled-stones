local luaunit = require("luaunit")
local GameSettings = require("models.gamesettings")

-- luacheck: globals TestGameSettings
TestGameSettings = {}

function TestGameSettings.test_tostring()
  local settings = GameSettings:new(23)
  local text = tostring(settings)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{__name = \"GameSettings\",side_count = 23}")
end
