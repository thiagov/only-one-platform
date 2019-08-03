local ScoreTick = Object:extend()

local good, bad = "good", "bad"
local up, down = "up", "down"
local itemTypes = {good, bad}

function ScoreTick:new(x, y, score)
  self.x = x
  self.y = y
  self.initialY = y
  self.score = score
  self.visible = true
  if self.score > 0 then
    self.itemType = good
    self.text = "+"..self.score
    self.direction = up
  else
    self.itemType = bad
    self.text = "-"..self.score
    self.direction = down
  end
end

function ScoreTick:update(dt)
  if self.direction == up then
    self.y = self.y - 10*dt
  else
    self.y = self.y + 10*dt
  end
  if math.abs(self.initialY - self.y) > 10 then
    self.visible = false
  end
end

function ScoreTick:draw()
  if self.itemType == good then
    love.graphics.setColor(0, 1, 0)
  else
    love.graphics.setColor(1, 0, 0)
  end
  if self.visible then
    love.graphics.print(self.text, self.x, self.y)
  end
end

return ScoreTick;
