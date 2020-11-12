local middleclass = require("middleclass")

local Stats = middleclass("Stats")

function Stats:initialize(current, minimal)
  self.current = current
  self.minimal = minimal
end

return Stats
