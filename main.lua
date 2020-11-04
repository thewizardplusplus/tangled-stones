package.path = "/sdcard/lovegame/vendor/?.lua;"
  .. "/sdcard/lovegame/vendor/?/init.lua;"
  .. "./vendor/?.lua;"
  .. "./vendor/?/init.lua"

local windfield = require("windfield")

local world = nil -- love.physics.World

function love.load()
  world = windfield.newWorld(0, 9.8, true)
end

function love.draw()
  world:draw()
end

function love.update(dt)
  world:update(dt)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
