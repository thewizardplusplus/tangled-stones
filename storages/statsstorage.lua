-- luacheck: no max comment line length

---
-- @classmod StatsStorage

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local json = require("luaserialization.json")
local Stats = require("models.stats")
local StatsGroup = require("models.statsgroup")

---
-- @table instance
-- @tfield string _path
-- @tfield StatsGroup _stats_group

local StatsStorage = middleclass("StatsStorage")

---
-- @function new
-- @tparam string path
-- @tparam int side_count [1, ∞)
-- @treturn StatsStorage
function StatsStorage:initialize(path, side_count)
  assertions.is_string(path)
  assertions.is_integer(side_count)

  local stats_group, err = json.load_from_json(
    path,
    StatsGroup.schema(),
    {
      Stats = Stats.from_options,
      StatsGroup = StatsGroup.from_options,
    },
    function(path) -- luacheck: no redefined
      assertions.is_string(path)

      local data, err = love.filesystem.read(path)
      return data, data == nil and err or nil
    end
  )
  if not stats_group then
    print("unable to load the stats: " .. err)

    stats_group = StatsGroup:new(side_count)
  else
    stats_group:set_side_count(side_count)
  end

  self._path = path
  self._stats_group = stats_group
end

---
-- @treturn StatsGroup
function StatsStorage:stats_group()
  return self._stats_group
end

---
-- @function save
function StatsStorage:save()
  local ok, err =
    json.save_to_json(self._path, self._stats_group, love.filesystem.write)
  if not ok then
    print("unable to save the stats: " .. err)
  end
end

return StatsStorage
