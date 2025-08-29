---
-- @classmod StatsStorage

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local jsonutils = require("jsonutils")
local Stats = require("models.stats")

---
-- @table instance
-- @tfield string _path
-- @tfield Stats _stats

local StatsStorage = middleclass("StatsStorage")

---
-- @function new
-- @tparam string path
-- @tparam number initial_minimal [0, ∞)
-- @treturn StatsStorage
function StatsStorage:initialize(path, initial_minimal)
  assertions.is_string(path)
  assertions.is_number(initial_minimal)

  path = path .. "/db.json"

  local stats, err = jsonutils.load_from_json(
    path,
    {
      type = "object",
      required = {"current", "minimal"},
      properties = {
        current = {
          type = "number",
          minimum = 0,
        },
        minimal = {
          type = "number",
          minimum = 0,
        },
      },
    },
    {
      Stats = function(options)
        assertions.is_table(options)

        return Stats:new(options.current, options.minimal)
      end,
    }
  )
  if not stats then
    print("unable to load the stats: " .. err)

    stats = Stats:new(0, initial_minimal)
  end

  self._path = path
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

    local ok, err = jsonutils.save_to_json(self._path, self._stats)
    if not ok then
      print("unable to save the stats: " .. err)
    end
  end

  self:reset()
end

return StatsStorage
