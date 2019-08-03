local Platform = Object:extend()

function Platform:new(x, y, width, height)
  self.width = width
  self.height = height
  self.x = x
  self.y = y
end

function Platform:updatePosition(x, y)
  self.x = x;
  self.y = y;
end

function Platform:update(dt)
end

function Platform:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

return Platform;
