Animation = require 'Animation'

local Hero = Object:extend()

function Hero:new()
  self.idleAnim = Animation(love.graphics.newImage("assets/sprites/idle.png"), 64, 64, 0.5)
  self.walkAnim = Animation(love.graphics.newImage("assets/sprites/walk.png"), 64, 64, 0.5)
end

function Hero:update(dt)
  self.idleAnim:update(dt)
  if love.keyboard.isDown("s") then
    self.walkAnim:update(dt)
  end
end

function Hero:draw()
  if love.keyboard.isDown("s") then
    self.walkAnim:draw(0, 100)
  else
    self.idleAnim:draw(0, 100)
  end
end

return Hero;
