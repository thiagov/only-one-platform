local Score = Object:extend()

function Score:new(x, y)
  self.score = 0
  self.x = x
  self.y = y
  self.fontSize = 20
  self.color = {1, 1, 1, 1}
  self.font = love.graphics.newImageFont("assets/scorefont.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
end

function Score:update(dt)
end

function Score:updateScore(item)
  self.score = self.score + item.score
end

function Score:draw()
  love.graphics.setFont(self.font)
  love.graphics.setColor(self.color)
  local messageText = "Score: "..self.score
  love.graphics.print(messageText, self.x-self.font:getWidth(messageText)/2, self.y)
end

return Score;
