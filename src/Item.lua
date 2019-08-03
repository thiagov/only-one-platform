local Item = Object:extend()

function Item:new(x, y, width, height)
  self.width = width
  self.height = height
  self.x = x
  self.y = y
end

function Item:updatePosition(x, y)
  self.x = x;
  self.y = y;
end

function Item:update(dt)
end

function Item:draw()
  love.graphics.setColor(1, 0, 1)
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

return Item;
