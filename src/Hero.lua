Animation = require 'Animation'

local Hero = Object:extend()
local gravity = 500

local falling, jumping, idle = "falling", "jumping", "idle"

function Hero:new(x, y, speed, width, height)
  self.idleAnim = Animation(love.graphics.newImage("assets/sprites/idle100x150.png"), 100, 150, 0.5)
  self.walkAnim = Animation(love.graphics.newImage("assets/sprites/walk100x150.png"), 100, 150, 0.5)
  self.animation = "idle"
  self.x = x
  self.y = y
  self.speed = speed
  self.width = width
  self.height = height
  self.status = idle
  self.jumpHeight = -500
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

  local probablyNewY = self.y + dt * self.velocity
  local xInPlatform = platform.x <= self.x + self.width and self.x <= platform.x + platform.width
  local landedOnPlatform = (self.y + self.height < platform.y and probablyNewY + self.height >= platform.y) and xInPlatform
  local isOnPlatform = (self.y + self.height == platform.y) and xInPlatform

  if (self.status == falling and landedOnPlatform) then
    self.status = idle
    self.velocity = 0
  elseif self.status == idle and love.keyboard.isDown("space") then
    self.status = jumping
    self.velocity = self.jumpHeight
  elseif (self.status == idle and not isOnPlatform) or (self.status == jumping and self.velocity >= 0) then
    self.status = falling
    self.velocity = gravity * dt
  end

  if self.status == idle then
    self.y = platform.y - self.height
  elseif self.velocity ~= 0 then
    self.y = probablyNewY
    self.velocity = self.velocity + gravity * dt
  end

end

function Hero:draw()
  love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
  love.graphics.print("Status: "..self.status, 1000, 1000)
  love.graphics.print("Velocity: "..self.velocity, 1000, 500)
  if self.animation == "moving" then
    self.walkAnim:draw(self.x, self.y)
  else
    self.idleAnim:draw(self.x, self.y)
  end
end

return Hero;
