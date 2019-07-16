Animation = require 'Animation'

local Hero = Object:extend()

function Hero:new(x, y)
  self.idleAnim = Animation(love.graphics.newImage("assets/sprites/idle.png"), 64, 64, 0.5)
  self.walkAnim = Animation(love.graphics.newImage("assets/sprites/walk.png"), 64, 64, 0.5)
  self.x = x;
  self.y = y;
  self.animation = "idle"
end

function Hero:update(dt)
  if love.keyboard.isDown("s", "w", "a", "d") then
    self.animation = "moving"
    self.walkAnim:update(dt)
    if love.keyboard.isDown("s") then
      self.y = self.y + 1
    end
    if love.keyboard.isDown("w") then
      self.y = self.y - 1
    end
    if love.keyboard.isDown("a") then
      self.x = self.x - 1
    end
    if love.keyboard.isDown("d") then
      self.x = self.x + 1
    end
  else
    self.animation = "idle"
    self.idleAnim:update(dt)
  end
end

function Hero:draw()
  if self.animation == "moving" then
    self.walkAnim:draw(self.x, self.y)
  else
    self.idleAnim:draw(self.x, self.y)
  end
end

return Hero;
