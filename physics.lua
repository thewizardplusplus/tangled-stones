---
-- @module physics

local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Rectangle = require("models.rectangle")

local physics = {}

---
-- @tparam windfield.World world
-- @tparam "static"|"dynamic" kind
-- @tparam Rectangle rectangle
-- @treturn windfield.Collider
function physics.make_collider(world, kind, rectangle)
  assertions.is_table(world)
  assertions.is_enumeration(kind, {"static", "dynamic"})
  assertions.is_instance(rectangle, Rectangle)

  local collider = world:newRectangleCollider(
    rectangle.x,
    rectangle.y,
    rectangle.width,
    rectangle.height
  )
  collider:setType(kind)

  return collider
end

---
-- @tparam {windfield.Collider,...} colliders
-- @tparam func handler func(collider: windfield.Collider): nil
function physics.process_colliders(colliders, handler)
  assertions.is_sequence(colliders, checks.is_table)
  assertions.is_function(handler)

  for _, collider in ipairs(colliders) do
    if not collider:isDestroyed() then
      handler(collider)
    end
  end
end

---
-- @tparam windfield.World world
function physics.draw(world)
  assertions.is_table(world)

  world:draw()

  -- draw joints
  love.graphics.setColor(222, 128, 64, 255)
  for _, joint in ipairs(world:getJoints()) do
    local x1, y1, x2, y2 = joint:getAnchors()
    if x1 and y1 and x2 and y2 then
      love.graphics.line(x1, y1, x2, y2)
    end
  end
end

return physics
