---
-- @classmod StatsStorage

local middleclass = require("middleclass")
local flatdb = require("flatdb")
local assertions = require("luatypechecks.assertions")
local Stats = require("models.stats")

---
-- @table instance
-- @tfield FlatDB _db
-- @tfield number _current

local StatsStorage = middleclass("StatsStorage")

---
-- @function new
-- @tparam string path
-- @tparam number initial_minimal [0, ∞)
-- @treturn StatsStorage
function StatsStorage:initialize(path, initial_minimal)
  assertions.is_string(path)
  assertions.is_number(initial_minimal)

  self._db = flatdb(path)
  if not self._db.stats then
    self._db.stats = {
      minimal = initial_minimal,
    }
  end

  self:reset()
end

---
-- @treturn Stats
function StatsStorage:stats()
  return Stats:new(self._current, self._db.stats.minimal)
end

---
-- @function increment
function StatsStorage:increment()
  self._current = self._current + 1
end

---
-- @function reset
function StatsStorage:reset()
  self._current = 0
end

---
-- @function finish
function StatsStorage:finish()
  if self._db.stats.minimal > self._current then
    self._db.stats.minimal = self._current
    self._db:save()
  end

  self:reset()
end

return StatsStorage
