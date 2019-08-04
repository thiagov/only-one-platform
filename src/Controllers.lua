local Controllers = Object:extend()
local initialTtl = 10

function Controllers:new(x, y)
  self.x = x
  self.y = y-60
  self.fontSize = 20
  self.color = {1, 1, 1, 1}
  self.onlyColor = {0.33, 0.784, 0, 1}
  self.oneColor = {1, 0, 0.376, 1}
  self.font = love.graphics.newImageFont("assets/scorefont.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
  self.ttl = initialTtl
end

function Controllers:update(dt)
  if self.ttl > 0 then
    self.ttl = self.ttl - dt
    self.color[4] = self.ttl / initialTtl
    self.onlyColor[4] = self.ttl / initialTtl
    self.oneColor[4] = self.ttl / initialTtl
  end
end

function Controllers:draw()
  if self.ttl > 0 then
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.color)
    local messageText = "A and D: move"
    love.graphics.print(messageText, self.x-self.font:getWidth(messageText)/2, self.y)
    messageText = "Space: jump"
    love.graphics.print(messageText, self.x-self.font:getWidth(messageText)/2, self.y+40)
    lineText = "Mouse click: warps the only one platform"
    messageText = "Mouse click: warps the "
    love.graphics.print(messageText, self.x-self.font:getWidth(lineText)/2, self.y+80)
    local newX = self.x - self.font:getWidth(lineText)/2 + self.font:getWidth(messageText)
    messageText = "only "
    love.graphics.setColor(self.onlyColor)
    love.graphics.print(messageText, newX, self.y+80)
    local newX = newX + self.font:getWidth(messageText)
    messageText = "one"
    love.graphics.setColor(self.oneColor)
    love.graphics.print(messageText, newX, self.y+80)
    local newX = newX + self.font:getWidth(messageText)
    messageText = " platform"
    love.graphics.setColor(self.color)
    love.graphics.print(messageText, newX, self.y+80)
  end
end

return Controllers;
