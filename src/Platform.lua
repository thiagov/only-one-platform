local Platform = Object:extend()

function Platform:new(x, y, width, height, xs, ys)
  self.sprite = love.graphics.newImage("assets/sprites/platform.png")
  self.mouseSprite = love.graphics.newImage("assets/sprites/platformMouse.png")
  self.width = width
  self.height = height
  self.x = x
  self.y = y
  self.xs = xs
  self.ys = ys
end

function Platform:updatePosition(x, y)
  self.x = x;
  self.y = y;
  self.sound = love.audio.newSource("assets/sound/platform.ogg", "static")
  self.sound:setVolume(0.4)
  self.sound:play()
end

function Platform:update(dt)
end

function Platform:draw()
  if false then
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
  end
  local mouseX, mouseY = love.mouse.getPosition()
  love.graphics.draw(self.mouseSprite, mouseX/self.xs-150/2, mouseY/self.ys-(84+30)/2)
  love.graphics.draw(self.sprite, self.x, self.y-30)
end

return Platform;
