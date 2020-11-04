function love.draw()
  love.graphics.print("Hello, world!", 100, 100)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
