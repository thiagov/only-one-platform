Animation = require 'Animation'

local Hero = Object:extend()

function Hero:new(x, y, speed, width, height)
  self.idleAnim = Animation(love.graphics.newImage("assets/sprites/idle100x150.png"), 100, 150, 0.5)
  self.walkAnim = Animation(love.graphics.newImage("assets/sprites/walk100x150.png"), 100, 150, 0.5)
  self.animation = "idle"
  self.x = x
  self.y = y
  self.speed = speed
  self.gravity = 100
  self.width = width
  self.height = height
end

function Hero:update(dt, platform)
  if love.keyboard.isDown("a", "d") then
    self.animation = "moving"
    self.walkAnim:update(dt)
    if love.keyboard.isDown("a") then
      self.x = self.x - dt * self.speed
    end
    if love.keyboard.isDown("d") then
      self.x = self.x + dt * self.speed
    end
  else
    self.animation = "idle"
    self.idleAnim:update(dt)
  end
  if self.y + self.height <= platform.y then
    self.y = self.y + dt * self.gravity
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
