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
  cai = true
  exatamente_em_cima = false

  if self.y <= platform.y then
    print("cai1")
    if self.y + dt * self.gravity >= platform.y then
      cai = false
      exatamente_em_cima = true
    end
  elseif self.y == platform.y and platform.x <= self.x + self.width and self.x <= platform.x + platform.width then
      cai = false
  end
  print("caigeral")


  if cai then
    self.y = self.y + dt * self.gravity
  elseif exatamente_em_cima then
    self.y = platform.y - self.height
  end
end

function Hero:draw()
  love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
  if self.animation == "moving" then
    self.walkAnim:draw(self.x, self.y)
  else
    self.idleAnim:draw(self.x, self.y)
  end
end

return Hero;
