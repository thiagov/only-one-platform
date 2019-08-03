local Item = Object:extend()

local linear, sin = "linear", "sin"
local movementTypes = {linear, sin}

function Item:new(x, y, width, height)
  self.width = width
  self.height = height
  self.x = x
  self.y = y
  self.yV = 0
  self.movementType = movementTypes[math.random(#movementTypes)]
  self.score = 50
end

function Item:update(dt)
  self.x = self.x - 500*dt
  if self.movementType == linear then
  else
    self.yV = self.yV + 3*dt
    self.y = self.y + 10*math.sin(self.yV)
  end
end

function Item:draw()
  love.graphics.setColor(1, 0, 1)
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Item:applyEffect()
  print('applied item effect')
end

return Item;
