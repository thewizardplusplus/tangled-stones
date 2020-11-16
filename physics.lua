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

return physics
