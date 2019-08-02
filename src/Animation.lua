local Animation = Object:extend()

function Animation:new(spriteSheet, width, height, duration)
  self.animation = {}
  self.animation.spriteSheet = spriteSheet
  self.animation.quads = {}

  for y = 0, spriteSheet:getHeight() - height, height do
    for x = 0, spriteSheet:getWidth() - width, width do
      table.insert(self.animation.quads, love.graphics.newQuad(x, y, width, height, spriteSheet:getDimensions()))
    end
  end

  self.animation.duration = duration or 1
  self.animation.currentTime = 0
end

function Animation:update(dt)
  self.animation.currentTime = self.animation.currentTime + dt
  if self.animation.currentTime >= self.animation.duration then
    self.animation.currentTime = self.animation.currentTime - self.animation.duration
  end
end

function Animation:draw(x, y)
  local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.quads) + 1
  love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], x, y, 0, 1)
end

return Animation;
