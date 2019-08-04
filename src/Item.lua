local Item = Object:extend()

local linear, sin, still = "linear", "sin", "still"
local movementTypes = {linear, sin}
local totalTtl = 10

Item.itemTypes = Object:extend()
Item.itemTypes.good = "good"
Item.itemTypes.bad = "bad"
Item.itemTypes.gooder = "gooder"

function Item:new(x, y, width, height, itemType)
  self.width = width
  self.height = height
  self.x = x
  self.y = y
  self.yV = 0
  self.visible = true
  self.timeVisible = 0
  self.movementType = movementTypes[math.random(#movementTypes)]
  self.itemType = itemType
  if self.itemType == Item.itemTypes.gooder then
    self.score = 500
    self.movementType = still
    self.color = {1, 1, 0, 1}
    self.ttl = totalTtl
    self.sprite = love.graphics.newImage("assets/sprites/lemon.png")
  elseif self.itemType == Item.itemTypes.good then
    self.score = 50
    self.color = {0, 0, 1, 1}
    self.sprite = love.graphics.newImage("assets/sprites/apple.png")
  elseif self.itemType == Item.itemTypes.bad then
    self.score = -100
    self.color = {1, 0, 0, 1}
    self.sprite = love.graphics.newImage("assets/sprites/cheese.png")
  end
  self.timeOnMovementType = 0
  self.velocity = 200 + math.random(300)
end

function Item:update(dt)
  if self.movementType == still then
    self.ttl = self.ttl - dt
    self.color[4] = self.ttl/totalTtl
    if self.ttl <= 0 then
      self.visible = false
    end
  else
    self:changeMovementType(dt)
    self.x = self.x - self.velocity*dt
    if self.movementType == sin then
      self.yV = self.yV + 3*dt
      self.y = self.y + 10*math.sin(self.yV)
    end
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
  --love.graphics.setColor(self.color)
  if self.visible then
    love.graphics.draw(self.sprite, self.x, self.y)
    --love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
  end
end

function Item:applyEffect()
  print('applied item effect')
end

return Item;
