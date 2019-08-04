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
  self.redSounds = {
    love.audio.newSource("assets/sound/get01.ogg", "static"),
    love.audio.newSource("assets/sound/get02.ogg", "static"),
    love.audio.newSource("assets/sound/get03.ogg", "static"),
    love.audio.newSource("assets/sound/get04.ogg", "static"),
    love.audio.newSource("assets/sound/get05.ogg", "static"),
    love.audio.newSource("assets/sound/get06.ogg", "static"),
    love.audio.newSource("assets/sound/get07.ogg", "static")
  }
  self.goldenSound = love.audio.newSource("assets/sound/getgold.ogg", "static")
  self.skullSound = love.audio.newSource("assets/sound/getskull.ogg", "static")
  self.currentSound = 1
end

function Score:update(dt)
end

function Score:updateScore(item)
  self.score = self.score + item.score
  if item.itemType == Item.itemTypes.good then
    self.redSounds[self.currentSound]:setVolume(0.4)
    self.redSounds[self.currentSound]:play()
    if self.currentSound + 1 > #self.redSounds then
      self.currentSound = 1
    else
      self.currentSound = self.currentSound + 1
    end
  elseif item.itemType == Item.itemTypes.gooder then
    self.goldenSound:setVolume(0.4)
    self.goldenSound:play()
  else
    self.skullSound:setVolume(0.4)
    self.skullSound:play()
  end
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
