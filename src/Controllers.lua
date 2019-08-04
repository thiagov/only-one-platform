local Controllers = Object:extend()
local initialTtl = 10

function Controllers:new(x, y)
  self.x = x
  self.y = y-60
  self.fontSize = 20
  self.color = {1, 1, 1, 1}
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
    messageText = "Mouse click: warps the only one platform"
    love.graphics.print(messageText, self.x-self.font:getWidth(messageText)/2, self.y+80)
  end
end

return Controllers;
