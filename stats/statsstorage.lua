local middleclass = require("middleclass")
local flatdb = require("flatdb")

local StatsStorage = middleclass("StatsStorage")

function StatsStorage:initialize(path, initial_minimal)
  self.current = 0

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

function StatsStorage:update()
  if self._db.stats.minimal > self.current then
    self._db.stats.minimal = self.current
    self._db:save()
  end

  self.current = 0
end

return StatsStorage
