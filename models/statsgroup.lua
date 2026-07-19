-- luacheck: no max comment line length

---
-- @classmod StatsGroup

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")
local Stats = require("models.stats")

---
-- @table instance
-- @tfield int _side_count [1, ∞)
-- @tfield {[string]=Stats,...} _stats_by_side_count

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
    required = {"_side_count", "_stats_by_side_count"},
    properties = {
      _side_count = {
        type = "number",
        minimum = 1,
        multipleOf = 1,
      },
      _stats_by_side_count = {
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

  return StatsGroup:new(options._side_count, options._stats_by_side_count)
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
-- @function new
-- @tparam int side_count [1, ∞)
-- @tparam[opt={}] {[string]=Stats,...} stats_by_side_count
-- @treturn StatsGroup
function StatsGroup:initialize(side_count, stats_by_side_count)
  stats_by_side_count = stats_by_side_count or {}

  assertions.is_integer(side_count)
  assertions.is_table(stats_by_side_count)

  self._side_count = side_count
  self._stats_by_side_count = stats_by_side_count

  self:reset()
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function StatsGroup:__data()
  return {
    _side_count = self._side_count,
    _stats_by_side_count = self._stats_by_side_count,
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

  self:reset() -- reset the current attempt for the previously selected side count

  self._side_count = side_count
  self:reset() -- reset the current attempt for the newly selected side count
end

---
-- @treturn Stats
function StatsGroup:stats()
  return self:_get_or_create_stats(self._side_count)
end

---
-- @function increment
function StatsGroup:increment()
  local stats = self:stats()
  stats.current = stats.current + 1
end

---
-- @function reset
function StatsGroup:reset()
  self:stats().current = 0
end

---
-- @treturn bool whether the minimal move count was updated
function StatsGroup:finish()
  local stats = self:stats()
  local was_updated = stats.minimal > stats.current
  if was_updated then
    stats.minimal = stats.current
  end

  self:reset()
  return was_updated
end

---
-- @tparam int side_count [1, ∞)
-- @treturn Stats
function StatsGroup:_get_or_create_stats(side_count)
  assertions.is_integer(side_count)

  local key = tostring(side_count)
  local stats = self._stats_by_side_count[key]
  if not stats then
    stats = Stats:new(0, StatsGroup.initial_minimal(side_count))
    self._stats_by_side_count[key] = stats
  end

  return stats
end

return StatsGroup
