local StatsStorage = require("stats.statsstorage")
local typeutils = require("typeutils")

local statsfactory = {}

function statsfactory.create_stats_storage(path, initial_minimal)
  assert(type(path) == "string")
  assert(typeutils.is_number_with_limits(initial_minimal, 0))

  local ok = love.filesystem.createDirectory(path)
  if not ok then
    return nil, "unable to create the stats DB"
  end

  local full_path = love.filesystem.getSaveDirectory() .. "/" .. path
  return StatsStorage:new(full_path, initial_minimal)
end

return statsfactory
