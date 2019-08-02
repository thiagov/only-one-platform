Object = require 'libs/classic'
Hero   = require 'Hero'

-- Load resources
function love.load()
  instance = Hero(0, 0)
end

-- Called continuously. dt = delta time
function love.update(dt)
  instance:update(dt)
end

-- All drawing comes here
function love.draw()
  instance:draw()
end