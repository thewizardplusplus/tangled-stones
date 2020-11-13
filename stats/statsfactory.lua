local StatsStorage = require("stats.statsstorage")

local statsfactory = {}

function statsfactory.create_stats_storage(path, initial_minimal)
  local ok = love.filesystem.createDirectory(path)
  if not ok then
    return nil, "unable to create the stats DB"
  end

  local full_path = love.filesystem.getSaveDirectory() .. "/" .. path
  return StatsStorage:new(full_path, initial_minimal)
end

return statsfactory
