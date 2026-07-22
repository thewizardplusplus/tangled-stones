local luaunit = require("luaunit")
local GameSettings = require("models.gamesettings")

-- luacheck: globals TestGameSettings
TestGameSettings = {}

function TestGameSettings.test_tostring()
  local settings = GameSettings:new(23, true)
  local text = tostring(settings)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"GameSettings\"," ..
    "auto_increment_side_count = true," ..
    "side_count = 23" ..
  "}")
end

function TestGameSettings.test_increment_side_count()
  local settings = GameSettings:new(GameSettings.MAX_SIDE_COUNT - 1, true)

  local was_incremented = settings:increment_side_count()

  luaunit.assert_true(was_incremented)
  luaunit.assert_equals(settings.side_count, GameSettings.MAX_SIDE_COUNT)
end

function TestGameSettings.test_increment_side_count_at_maximum()
  local settings = GameSettings:new(GameSettings.MAX_SIDE_COUNT, true)

  local was_incremented = settings:increment_side_count()

  luaunit.assert_false(was_incremented)
  luaunit.assert_equals(settings.side_count, GameSettings.MAX_SIDE_COUNT)
end

function TestGameSettings.test_increment_side_count_when_disabled()
  local side_count = 5
  local settings = GameSettings:new(side_count, false)

  local was_incremented = settings:increment_side_count()

  luaunit.assert_false(was_incremented)
  luaunit.assert_equals(settings.side_count, side_count)
end
