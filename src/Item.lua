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
  self.timeOnMovementType = 0
  self.velocity = 200 + math.random(300)
end

function Item:update(dt)
  self:changeMovementType(dt)
  self.x = self.x - self.velocity*dt
  if self.movementType == sin then
    self.yV = self.yV + 3*dt
    self.y = self.y + 10*math.sin(self.yV)
  end
end

function Item:changeMovementType(dt)
  self.timeOnMovementType = self.timeOnMovementType + dt
  if self.timeOnMovementType > 1 then
    self.movementType = movementTypes[math.random(#movementTypes)]
    self.timeOnMovementType = 0
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
