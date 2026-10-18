local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local json = require("luaserialization.json")
local GameSettings = require("models.gamesettings")

-- luacheck: globals TestGameSettings
TestGameSettings = {}

function TestGameSettings.test_from_json_success()
  local settings, err = json.from_json(
    [[{
      "__name": "GameSettings",
      "side_count": 23,
      "auto_increment_side_count": true
    }]],
    GameSettings.schema(),
    { GameSettings = GameSettings.from_options }
  )

  luaunit.assert_is_table(settings)
  luaunit.assert_is_true(checks.is_instance(settings, GameSettings))

  luaunit.assert_is_number(settings.side_count)
  luaunit.assert_equals(settings.side_count, 23)

  luaunit.assert_is_boolean(settings.auto_increment_side_count)
  luaunit.assert_is_true(settings.auto_increment_side_count)

  luaunit.assert_is_nil(err)
end

function TestGameSettings.test_from_json_error()
  local settings, err = json.from_json(
    [[{
      "__name": "GameSettings",
      "side_count": "invalid",
      "auto_increment_side_count": true
    }]],
    GameSettings.schema(),
    { GameSettings = GameSettings.from_options }
  )

  luaunit.assert_is_nil(settings)

  luaunit.assert_is_string(err)
  luaunit.assert_str_matches(
    err,
    "^invalid data: " ..
      [[property "side_count" validation failed: ]] ..
      "wrong type: " ..
      "expected number, got string$"
  )
end

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
