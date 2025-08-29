---
-- @classmod StatsStorage

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local json = require("luaserialization.json")
local Stats = require("models.stats")

---
-- @table instance
-- @tfield string _path
-- @tfield Stats _stats

local StatsStorage = middleclass("StatsStorage")

---
-- @tparam string path
-- @tparam number initial_minimal [0, ∞)
-- @treturn StatsStorage
-- @error error message
function StatsStorage.static.create(path, initial_minimal)
  assertions.is_string(path)
  assertions.is_number(initial_minimal)

  local ok = love.filesystem.createDirectory(path)
  if not ok then
    return nil, "unable to create the stats DB"
  end

  return StatsStorage:new(path, initial_minimal)
end

---
-- @function new
-- @tparam string path
-- @tparam number initial_minimal [0, ∞)
-- @treturn StatsStorage
function StatsStorage:initialize(path, initial_minimal)
  assertions.is_string(path)
  assertions.is_number(initial_minimal)

  local completed_path = path .. "/db.json"
  local stats, err = json.load_from_json(
    completed_path,
    Stats.schema(),
    { Stats = Stats.from_options },
    function(path) -- luacheck: no redefined
      assertions.is_string(path)

      local data, err = love.filesystem.read(path)
      return data, data == nil and err or nil
    end
  )
  if not stats then
    print("unable to load the stats: " .. err)

    stats = Stats:new(0, initial_minimal)
  end

  self._path = completed_path
  self._stats = stats

  self:reset()
end

---
-- @treturn Stats
function StatsStorage:stats()
  return self._stats
end

---
-- @function increment
function StatsStorage:increment()
  self._stats.current = self._stats.current + 1
end

---
-- @function reset
function StatsStorage:reset()
  self._stats.current = 0
end

---
-- @function finish
function StatsStorage:finish()
  if self._stats.minimal > self._stats.current then
    self._stats.minimal = self._stats.current

    local ok, err =
      json.save_to_json(self._path, self._stats, love.filesystem.write)
    if not ok then
      print("unable to save the stats: " .. err)
    end
  end

  self:reset()
end

return StatsStorage
