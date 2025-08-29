local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local json = require("luaserialization.json")
local Stats = require("models.stats")

-- luacheck: globals TestStats
TestStats = {}

function TestStats.test_from_json_success()
  local stats, err = json.from_json(
    [[{ "__name": "Stats", "minimal": 23, "current": 42 }]],
    Stats.schema(),
    { Stats = Stats.from_options }
  )

  luaunit.assert_is_table(stats)
  luaunit.assert_is_true(checks.is_instance(stats, Stats))

  luaunit.assert_is_number(stats.minimal)
  luaunit.assert_equals(stats.minimal, 23)

  luaunit.assert_is_number(stats.current)
  luaunit.assert_equals(stats.current, 42)

  luaunit.assert_is_nil(err)
end

function TestStats.test_from_json_error()
  local stats, err = json.from_json(
    [[{ "__name": "Stats", "minimal": "invalid", "current": 42 }]],
    Stats.schema(),
    { Stats = Stats.from_options }
  )

  luaunit.assert_is_nil(stats)

  luaunit.assert_is_string(err)
  luaunit.assert_str_matches(
    err,
    "^invalid data: " ..
      [[property "minimal" validation failed: ]] ..
      "wrong type: " ..
      "expected number, got string$"
  )
end

function TestStats.test_tostring()
  local settings = Stats:new(42, 23)
  local text = tostring(settings)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{__name = \"Stats\",current = 42,minimal = 23}")
end
