local luaunit = require("luaunit")
local StatsGroup = require("models.statsgroup")
local Stats = require("models.stats")

-- luacheck: globals TestStatsGroup
TestStatsGroup = {}

function TestStatsGroup.test_new()
  local stats_group = StatsGroup:new(5)

  luaunit.assert_equals(stats_group._side_count, 5)
  luaunit.assert_equals(stats_group._stats_by_side_count, {
    ["5"] = Stats:new(0, 250),
  })
end

function TestStatsGroup.test_tostring()
  local stats_group = StatsGroup:new(23)
  stats_group:set_side_count(42)

  local text = tostring(stats_group)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"StatsGroup\"," ..
    "_side_count = 42," ..
    "_stats_by_side_count = {" ..
      "[\"23\"] = {" ..
        "__name = \"Stats\"," ..
        "current = 0," ..
        "minimal = 5290" ..
      "}," ..
      "[\"42\"] = {" ..
        "__name = \"Stats\"," ..
        "current = 0," ..
        "minimal = 17640" ..
      "}" ..
    "}" ..
  "}")
end

function TestStatsGroup.test_set_side_count()
  local stats_group = StatsGroup:new(5)
  stats_group._stats_by_side_count["5"].current = 23
  stats_group._stats_by_side_count["12"] = Stats:new(42, 1440)

  stats_group:set_side_count(12)

  luaunit.assert_equals(stats_group._side_count, 12)
  luaunit.assert_equals(stats_group._stats_by_side_count, {
    ["5"] = Stats:new(0, 250),
    ["12"] = Stats:new(0, 1440),
  })
end

function TestStatsGroup.test_increment()
  local stats_group = StatsGroup:new(5)

  local increment_count = 12
  for _ = 1, increment_count do
    stats_group:increment()
  end

  luaunit.assert_equals(stats_group._side_count, 5)
  luaunit.assert_equals(stats_group._stats_by_side_count, {
    ["5"] = Stats:new(increment_count, 250),
  })
end

function TestStatsGroup.test_finish_with_new_minimal()
  local stats_group = StatsGroup:new(5)
  stats_group._stats_by_side_count["5"].current = 12

  local was_updated = stats_group:finish()

  luaunit.assert_true(was_updated)
  luaunit.assert_equals(stats_group._side_count, 5)
  luaunit.assert_equals(stats_group._stats_by_side_count, {
    ["5"] = Stats:new(0, 12),
  })
end

function TestStatsGroup.test_finish_without_new_minimal()
  local stats_group = StatsGroup:new(5)
  stats_group._stats_by_side_count["5"].current = 251

  local was_updated = stats_group:finish()

  luaunit.assert_false(was_updated)
  luaunit.assert_equals(stats_group._side_count, 5)
  luaunit.assert_equals(stats_group._stats_by_side_count, {
    ["5"] = Stats:new(0, 250),
  })
end
