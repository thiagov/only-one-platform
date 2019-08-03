Object = require 'libs/classic'
Hero   = require 'Hero'
Platform = require 'Platform'

-- Load resources
function love.load()
  love.window.setFullscreen(true, "desktop")
  desktopWidth, desktopHeight, flags = love.window.getMode( )
  width, height = 1920, 1080
  xs = desktopWidth/width
  ys = desktopHeight/height
  font = love.graphics.newFont(14)
  platformInstance = Platform(10/xs, 200/ys, 150*xs, 50*ys)
  heroInstance = Hero(0, 0, 200, 100*xs, 150*ys)
end

-- Called continuously. dt = delta time
function love.update(dt)
  updateStart = love.timer.getTime()
  platformInstance:update(dt)
  heroInstance:update(dt, platformInstance)
  updateResult = love.timer.getTime() - updateStart
end

-- All drawing comes here
function love.draw()
  drawStart = love.timer.getTime()
  love.graphics.scale(xs, ys)
  platformInstance:draw()
  heroInstance:draw()
  drawResult = love.timer.getTime() - drawStart
  drawUpdateDrawBars()
end

function drawUpdateDrawBars()
  dangerLine = 0.8
  barHeight = 10
  fontHeight = font:getHeight()
  if (updateResult*1000>dangerLine) then
    love.graphics.setColor(1, 1, 0)
  else
    love.graphics.setColor(1, 1, 0, 0.2)
  end
  love.graphics.rectangle("fill", 0, height-barHeight*2, width*updateResult*1000, barHeight)
  if (drawResult*1000>dangerLine) then
    love.graphics.setColor(1, 0, 0)
  else
    love.graphics.setColor(1, 0, 0, 0.2)
  end
  love.graphics.rectangle("fill", 0, height-barHeight, width*drawResult*1000, barHeight)

  love.graphics.setColor(1, 1, 1, 0.2)
  love.graphics.rectangle("fill", width*dangerLine, height-barHeight*2, 2, barHeight*2)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Update: "..updateResult*1000 .."ms", 10, height-barHeight*2+barHeight/2-fontHeight/2)
  love.graphics.print("Draw: "..updateResult*1000 .."ms", 10, height-barHeight+barHeight/2-fontHeight/2)
end

function love.mousepressed(x, y, button, istouch)
  if button == 1 then
    platformInstance:updatePosition(x/xs, y/ys)
  end
end
