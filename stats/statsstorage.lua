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

  self:reset()
end

function StatsStorage:stats()
  return Stats:new(self.current, self._db.stats.minimal)
end

function StatsStorage:increment()
  self.current = self.current + 1
end

function StatsStorage:reset()
  self.current = 0
end

function StatsStorage:update()
  if self._db.stats.minimal > self.current then
    self._db.stats.minimal = self.current
    self._db:save()
  end

  self:reset()
end

return StatsStorage
