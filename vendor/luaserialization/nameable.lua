-- luacheck: no max comment line length

--- ⚠️. This class is a mixin that adds the `__name` metaproperty to a class created by library [middleclass](https://github.com/kikito/middleclass). This metaproperty equals to the `name` property of the mix target class.
-- @classmod Nameable

local assertions = require("luatypechecks.assertions")

local Nameable = {}

---
-- @tparam tab class a class created by library [middleclass](https://github.com/kikito/middleclass)
function Nameable:included(class) -- luacheck: no unused
  assertions.is_table(class)
  assertions.has_properties(class, {"static"})
  assertions.has_properties(class.static, {"allocate"})

  local original_allocate = class.static.allocate
  class.static.allocate = function(class, ...) -- luacheck: no redefined
    assertions.is_table(class)
    assertions.has_properties(class, {"name"})

    local instance = original_allocate(class, ...)
    local instance_metatable = getmetatable(instance)
    if instance_metatable ~= nil then
      instance_metatable.__name = class.name
    end

    return instance
  end
end

return Nameable
