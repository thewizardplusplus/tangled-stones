local physics = {}

function physics.make_collider(world, kind, rectangle)
  local collider = world:newRectangleCollider(
    rectangle.x,
    rectangle.y,
    rectangle.width,
    rectangle.height
  )
  collider:setType(kind)

  return collider
end

function physics.process_colliders(colliders, handler)
  for _, collider in ipairs(colliders) do
    if not collider:isDestroyed() then
      handler(collider)
    end
  end
end

function physics.draw(world)
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
