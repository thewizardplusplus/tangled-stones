-- luacheck: no max comment line length

---
-- @classmod StatsGroup

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")
local Stats = require("models.stats")

local StatsGroup = middleclass("StatsGroup")
StatsGroup:include(Nameable)
StatsGroup:include(Stringifiable)

---
-- @function schema
-- @static
-- @treturn tab JSON Schema for this class
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function StatsGroup.static.schema()
  return {
    type = "object",
    required = {"side_count", "stats_by_side_count"},
    properties = {
      side_count = { type = "number", minimum = 1, multipleOf = 1 },
      stats_by_side_count = {
        type = "object",
        patternProperties = { ["^[1-9]%d*$"] = Stats.schema() },
        additionalProperties = false,
      },
    },
  }
end

---
-- @function from_options
-- @static
-- @tparam tab options constructor options conforming to the JSON Schema
--   returned by @{StatsGroup.schema|StatsGroup.schema()}
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
-- @treturn StatsGroup
function StatsGroup.static.from_options(options)
  assertions.is_table(options)

  return StatsGroup:new(options.side_count, options.stats_by_side_count)
end

---
-- @function initial_minimal
-- @static
-- @tparam int side_count [1, ∞)
-- @treturn int
function StatsGroup.static.initial_minimal(side_count)
  assertions.is_integer(side_count)

  return math.floor(math.pow(side_count, 2)) * 10
end

---
-- @table instance
-- @tfield int _side_count [1, ∞)
-- @tfield {[string]=Stats,...} _stats_by_side_count

---
-- @function new
-- @tparam int side_count [1, ∞)
-- @tparam[opt={}] {[string]=Stats,...} stats_by_side_count
-- @treturn StatsGroup
function StatsGroup:initialize(side_count, stats_by_side_count)
  stats_by_side_count = stats_by_side_count or {}

  assertions.is_integer(side_count)
  assertions.is_table(
    stats_by_side_count,
    checks.is_string,
    checks.make_instance_checker(Stats)
  )

  self._side_count = side_count
  self._stats_by_side_count = {}
  for key, stats in pairs(stats_by_side_count) do
    self._stats_by_side_count[key] = Stats:new(stats.current, stats.minimal)
  end

  self:stats():reset()
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function StatsGroup:__data()
  return {
    side_count = self._side_count,
    stats_by_side_count = self._stats_by_side_count,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

---
-- @tparam int side_count [1, ∞)
function StatsGroup:set_side_count(side_count)
  assertions.is_integer(side_count)

  self:stats():reset() -- reset the current attempt for the previously selected side count

  self._side_count = side_count
  self:stats():reset() -- reset the current attempt for the newly selected side count
end

---
-- ⚠️. Get or create stats for the selected side count.
-- @treturn Stats
function StatsGroup:stats()
  local key = tostring(self._side_count)
  local stats = self._stats_by_side_count[key]
  if not stats then
    stats = Stats:new(0, StatsGroup.initial_minimal(self._side_count))
    self._stats_by_side_count[key] = stats
  end

  return stats
end

return StatsGroup
