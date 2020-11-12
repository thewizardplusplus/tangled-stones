local middleclass = require("middleclass")
local flatdb = require("flatdb")
local Stats = require("models.stats")

local StatsStorage = middleclass("StatsStorage")

function StatsStorage:initialize(path, initial_minimal)
  self._db = flatdb(path)
  if not self._db.stats then
    self._db.stats = {
      minimal = initial_minimal,
    }
  end
end

function StatsStorage:minimal()
  return self._db.stats.minimal
end

function StatsStorage:update(current)
  if self._db.stats.minimal > current then
    self._db.stats.minimal = current
    self._db:save()
  end

  return Stats:new(current, self._db.stats.minimal)
end

return StatsStorage
