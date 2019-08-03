Object    = require 'libs/classic'
Hero      = require 'Hero'
Platform  = require 'Platform'
Item      = require 'Item'
ScoreTick = require 'ScoreTick'

-- Load resources
function love.load()
  math.randomseed(os.time())
  love.window.setFullscreen(true, "desktop")
  desktopWidth, desktopHeight, flags = love.window.getMode( )
  width, height = 1920, 1080
  xs = desktopWidth/width
  ys = desktopHeight/height
  font = love.graphics.newFont(14)
  platformInstance = Platform(10, 200, 150, 50)
  itemsInstance = {}
  scoreTicksInstance = {}
  heroInstance = Hero(0, 0, 200, 100, 150)
  score = 0
  generationTime = 0
end

-- Called continuously. dt = delta time
function love.update(dt)
  updateStart = love.timer.getTime()
  platformInstance:update(dt)
  heroInstance:update(dt, platformInstance, itemsInstance)
  for i, item in ipairs(itemsInstance) do
    item:update(dt)
  end
  for i, scoreTick in ipairs(scoreTicksInstance) do
    scoreTick:update(dt)
  end
  local removedItems = handleCollision()
  updateScore(removedItems)
  removeItemsOutOfWorld()
  computeGameOver()
  generateRandomItems(dt)
  updateResult = love.timer.getTime() - updateStart
end

-- All drawing comes here
function love.draw()
  drawStart = love.timer.getTime()
  love.graphics.scale(xs, ys)
  platformInstance:draw()
  heroInstance:draw()
  for i, item in ipairs(itemsInstance) do
    item:draw()
  end
  for i, scoreTick in ipairs(scoreTicksInstance) do
    scoreTick:draw()
  end
  drawResult = love.timer.getTime() - drawStart
  drawUpdateDrawBars()

  love.graphics.print("Score: "..score, width - 100, 0)
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
    platformInstance:updatePosition(x/xs - platformInstance.width/2, y/ys - platformInstance.height/2)
  end
end

function handleCollision()
  local removed = {}
  for i, item in ipairs(itemsInstance) do
    if collide(heroInstance, item) then
      table.insert(removed, table.remove(itemsInstance, i))
    end
  end
  return removed
end

function updateScore(removed)
  for i, item in ipairs(removed) do
    score = score + item.score
    table.insert(scoreTicksInstance, ScoreTick(item.x+item.width/2, item.y+item.height/2, item.score))
  end
end

function collide(hero, item)
  local x1, y1, w1, h1 = hero.x, hero.y, hero.width, hero.height
  local x2, y2, w2, h2 = item.x, item.y, item.width, item.height

  return x1 < x2+w2 and
  x2 < x1+w1 and
  y1 < y2+h2 and
  y2 < y1+h1
end

function removeItemsOutOfWorld()
  for i, item in ipairs(itemsInstance) do
    if (item.x + item.width) < 0 or not item.visible then
      table.remove(itemsInstance, i)
    end
  end
  for i, scoreTick in ipairs(scoreTicksInstance) do
    if not scoreTick.visible then
      table.remove(scoreTicksInstance, i)
    end
  end
end

function computeGameOver()
  if heroInstance.y > height then
    -- print('morreu')
  end
end

local itemTypes = {
  Item.itemTypes.good,
  Item.itemTypes.good,
  Item.itemTypes.good,
  Item.itemTypes.good,
  Item.itemTypes.good,
  Item.itemTypes.bad,
  Item.itemTypes.bad,
  Item.itemTypes.bad,
  Item.itemTypes.bad,
  Item.itemTypes.bad,
  Item.itemTypes.gooder
}
function generateRandomItems(dt)
  generationTime = generationTime + dt
  if generationTime > 1 then
    generationTime = 0
    local itemHeight, itemWidth = 50, 50
    local itemType = itemTypes[math.random(#itemTypes)]
    local itemPositionY = itemHeight + math.random(height - itemHeight)
    local itemPositionX = width
    if itemType == Item.itemTypes.gooder then
      itemPositionX = itemWidth + math.random(width - itemWidth)
    end
    table.insert(itemsInstance, Item(itemPositionX, itemPositionY, itemWidth, itemHeight, itemType))
  end
end
