Animation = require 'Animation'

local Hero = Object:extend()
local gravity = 1000

local falling, jumping = "falling", "jumping", "idle"

function Hero:new(x, y, speed, width, height)
  self.idleAnim = Animation(love.graphics.newImage("assets/sprites/idle100x150.png"), 100, 150, 0.5)
  self.walkAnim = Animation(love.graphics.newImage("assets/sprites/walk100x150.png"), 100, 150, 0.5)
  self.animation = "idle"
  self.x = x
  self.y = y
  self.speed = speed
  self.width = width
  self.height = height
  self.status = idle;
  self.jumpHeight = -300
  self.timeFalling = 0
  self.velocity = 0
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

  if (self.y + self.height < platform.y and (self.y + dt * gravity) + self.height >= platform.y)
        or (self.y + self.height == platform.y and platform.x <= self.x + self.width and self.x <= platform.x + platform.width) then
    self.status = idle
  else
    self.status = falling
  end

  if self.status == falling then
    self.timeFalling = self.timeFalling + dt
    self.y = self.y + (dt * (self.velocity + dt * gravity / 2))
    self.velocity = self.velocity + dt * gravity
  else
    self.timeFalling = 0
    self.velocity = 0
    self.y = platform.y - self.height
  end

  if love.keyboard.isDown("space") then
    if not self.status == falling then
      self.y = self.y + self.jumpHeight * dt
      self.jumpHeight = self.jumpHeight - self.jumpHeight * dt
    end
  end
end

function Hero:handleKey(key)
  if key == "space" then
    print("space pressed")
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
