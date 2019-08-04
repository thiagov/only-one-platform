local ScoreTick = Object:extend()

local good, bad = "good", "bad"
local up, down = "up", "down"
local itemTypes = {good, bad}

function ScoreTick:new(x, y, score)
  self.x = x
  self.y = y
  self.ttl = 1
  self.initialY = y
  self.score = score
  self.visible = true
  if self.score > 0 then
    self.itemType = good
    self.text = "+"..self.score
    self.direction = up
    self.color = {0, 0.6, 0.2, 1}
  else
    self.itemType = bad
    self.text = "-"..self.score
    self.direction = down
    self.color = {1, 0, 0, 1}
  end
end

function ScoreTick:update(dt)
  if self.direction == up then
    self.y = self.y - 10*dt
  else
    self.y = self.y + 10*dt
  end
  self.ttl = self.ttl - dt
  self.color[4] = self.ttl
  if self.ttl <= 0 then
    self.visible = false
  end
end

function ScoreTick:draw()
  love.graphics.setNewFont(20)
  love.graphics.setColor(self.color)
  if self.visible then
    love.graphics.print(self.text, self.x, self.y)
  end
end

return ScoreTick;
