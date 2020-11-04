package.path = "/sdcard/lovegame/vendor/?.lua;"
  .. "/sdcard/lovegame/vendor/?/init.lua;"
  .. "./vendor/?.lua;"
  .. "./vendor/?/init.lua"

function love.draw()
  love.graphics.print("Hello, world!", 100, 100)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
