local Score = Object:extend()

function Score:new(x, y)
  self.score = 0
  self.x = x
  self.y = y
  self.fontSize = 20
  self.color1 = {0.33, 0.784, 0, 1}
  self.color2 = {1, 0, 0.376, 1}
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
  local lineText = "Score: "..self.score
  local messageText = "Score:"
  love.graphics.setColor(self.color1)
  love.graphics.print(messageText, self.x-self.font:getWidth(lineText)/2, self.y)
  local newX = self.x - self.font:getWidth(lineText)/2 + self.font:getWidth(messageText)
  love.graphics.setColor(self.color2)
  local messageText = " "..self.score
  love.graphics.print(messageText, newX, self.y)
end

return Score;
