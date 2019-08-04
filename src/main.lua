Object      = require 'libs/classic'
Hero        = require 'Hero'
Platform    = require 'Platform'
Item        = require 'Item'
ScoreTick   = require 'ScoreTick'
Score       = require 'Score'
Controllers = require 'Controllers'

-- Generate vignette
function generateVignette(size, border)
  vignette = love.graphics.newCanvas(width, size)
  love.graphics.setCanvas(vignette)
  for i=1, border+1, 1 do
    love.graphics.setColor(0, 0, 0, i/(border+1))
    love.graphics.rectangle("fill", 0, i, width, 1)
    love.graphics.rectangle("fill", 0, size-i, width, 1)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, border, width, size-border*2)
  end

  love.graphics.setCanvas()
  return vignette
end

-- Draw feathered borders
function drawFeatheredBorders(drawable, position, size, border)
  for i=1, border+1, 1 do
    love.graphics.setColor(1, 1, 1, i/(border+1))
    --quadfulA = love.graphics.newQuad(0, position-1+i, width, 1, width, height)
    love.graphics.draw(drawable, quadfulA[i], 0, position-1+i)

    --quadfulB = love.graphics.newQuad(0, position+size-i, width, 1, width, height)
    love.graphics.draw(drawable, quadfulB[i], 0, position+size-i)
  end

  --quadfulC = love.graphics.newQuad(0, position+border, width, size-border*2, width, height)
  love.graphics.draw(drawable, quadfulC, 0, position+border)
end

function generateHorizontalCoordinateOffsets(number)
   local substitutionString = ""
   -- vBlurOffsets[ 6] = VertexTexCoord.xy + prescaler*vec2(-1, 0.0)/love_ScreenSize.x;
   local index = 0
   for i = 0,number,1 do
      if i ~= number/2 then
   -- note that this expression uses both "i" and "index"
   substitutionString = substitutionString .. "vBlurOffsets[" .. tostring(index) .. "] = VertexTexCoord.xy + prescaler*vec2(" .. tostring(i - number/2) .. ", 0.0)/love_ScreenSize.x;\n"
   index = index+1
      end
   end
   return substitutionString
end

function generateVerticalCoordinateOffsets(number)
   local substitutionString = ""
   -- vBlurOffsets[ 0] = VertexTexCoord.xy + prescaler*vec2(0.0, -7)/love_ScreenSize.y;
   local index = 0
   for i = 0,number,1 do
      if i ~= number/2 then
   -- note that this expression uses both "i" and "index"
   substitutionString = substitutionString .. "vBlurOffsets[" .. tostring(index) .. "] = VertexTexCoord.xy + prescaler*vec2(0.0, " .. tostring(i - number/2) .. ")/love_ScreenSize.y;\n"
   index = index+1
      end
   end
   return substitutionString
end

function loadShader()
   local blurSamples = 16 -- has to be even, 30 is max on nvidia hardware, 16 on ES2.0 hardware.
   local horizontalVertexSource = love.filesystem.read("material-horizontal.vsh")
   horizontalVertexSource = horizontalVertexSource:gsub("${{POPULATE_BLUR_OFFSETS}}", generateHorizontalCoordinateOffsets(blurSamples))
   horizontalVertexSource = horizontalVertexSource:gsub("${{NUM_BLUR_SAMPLES}}", blurSamples)
   
   local verticalVertexSource = love.filesystem.read("material-vertical.vsh")
   verticalVertexSource = verticalVertexSource:gsub("${{POPULATE_BLUR_OFFSETS}}", generateVerticalCoordinateOffsets(blurSamples))
   verticalVertexSource = verticalVertexSource:gsub("${{NUM_BLUR_SAMPLES}}", blurSamples)
   
   local fragmentSource = love.filesystem.read("material.fsh")
   
   horizontalShader = love.graphics.newShader(horizontalVertexSource, fragmentSource)
   verticalShader = love.graphics.newShader(verticalVertexSource, fragmentSource)
end

function die()
  if not ded then
    dedStart = love.timer.getTime()
    aliveBGM:setVolume(0)
    dedBGM:setVolume(0.7)
    dedChord:setVolume(0.4)
    dedChord:play()
    chosenDiededMessage = math.random(1,tableLength(diededMessages))
  end

  ded=true
end

function initializeDed()
  dedShader = love.graphics.newShader("ded.lua")

  loadShader()
  canvasA, canvasB, canvasC = love.graphics.newCanvas(), love.graphics.newCanvas(), love.graphics.newCanvas()

  vignetteLove = generateVignette(dedSize, dedBorder)
  quadful = love.graphics.newQuad(0, dedPosition, width, dedSize, width, height)

  quadfulA = {}
  for i=1,dedBorder+1,1 do
    table.insert(quadfulA, love.graphics.newQuad(0, dedPosition-1+i, width, 1, width, height))
  end

  quadfulB = {}
  for i=1,dedBorder+1,1 do
    table.insert(quadfulB, love.graphics.newQuad(0, dedPosition+dedSize-i, width, 1, width, height))
  end

  quadfulC = love.graphics.newQuad(0, dedPosition+dedBorder, width, dedSize-dedBorder*2, width, height)
end


function drawDedBefore()
  if ded then
    -- love.graphics.setCanvas(canvasA)--here!
    dedFinish = love.timer.getTime() - dedStart
    dedShader:send("timing", dedFinish)
    dedShader:send("maxTiming", dedTime*1000)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setShader(dedShader)
  end
end

function drawRoughEffect()
  love.graphics.setColor(1, 1, 1, 0.2)
  love.graphics.draw(roughEffect)
  love.graphics.setColor(1, 1, 1, 1)
end

function drawDedAfter()
  if ded then
    -- love.graphics.scale(1/xs, 1/ys)
    local prescalerCoefficient = math.min(dedBlur*dedFinish/dedTime, dedBlur)
    horizontalShader:send("prescaler", prescalerCoefficient*2.5)
    verticalShader:send("prescaler", prescalerCoefficient*2.5)

    love.graphics.setCanvas(canvasB)
    love.graphics.setShader(horizontalShader) 
    love.graphics.draw(canvasA)
    love.graphics.setShader()
    love.graphics.setCanvas(canvasC)
    love.graphics.draw(canvasA)

    love.graphics.setShader(verticalShader)

    love.graphics.draw(canvasB, quadful, 0, dedPosition)

    love.graphics.setCanvas()
    love.graphics.setShader()
    love.graphics.draw(canvasA)
    drawFeatheredBorders(canvasC, dedPosition, dedSize, dedBorder)
    love.graphics.draw(canvasC, quadful, 0, dedPosition)  
  
    love.graphics.setColor(1, 1, 1, math.min(dedOpacity*dedFinish/dedTime, dedOpacity))
    love.graphics.draw(vignetteLove, 0, dedPosition)

    love.graphics.draw(diededMessages[chosenDiededMessage], 0, dedPosition+dedSize/2-108/1.75+math.max(dedMove-dedMove*dedFinish/dedTime, 0))
    love.graphics.setColor(1, 1, 1, 1)
  end
end


function rgb(r, g, b, a)
  if not a then a=1 end
  return {r/255, g/255, b/255, a}
end

function rgba(rgbcolor,a)
  return {rgbcolor[1],rgbcolor[2],rgbcolor[3],a}
end

function tableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function cycleColor(min, max)
  if math.floor(min/max)%2==1 then return max-(min%max+1)
  else return min%max+1 end
end

function animateBG(dt)
  for i=1,tableLength(bgX),1 do
    bgX[i] = bgX[i] - bgVX[i]*dt
    bgX[i] = bgX[i]%(width/2)-width
  end

  moveStars(dt)
end

function moveStars(dt)
  for i=1, starRows, 1 do
    starRowX[i] = starRowX[i]-starVX[i]*dt
    if starRowX[i] <= -starDeadline*2 then starRowX[i] = starRowX[i]+starDeadline*1.5 end
  end

  starRotation = starRotation+starVRotation*dt
  if starRotation >= math.pi*2 then starRotation = starRotation-math.pi*2 end
end

function drawStars()
  for c=1, starColumns, 1 do
    for r=1, starRows, 1 do
      love.graphics.setColor(bgColor[math.max(1,cycleColor(r-1,tableLength(bgColor)))])
      love.graphics.draw(bgStar, starX+starRowX[r]+c*starPaddingX, starY+r*starPaddingY, starRotation+(c-1)*(math.pi*2)/2+(r-1)*starRotationCoefficientY, 1, 1, bgStar:getWidth()/2, bgStar:getHeight()/2)
    end
  end
end

function drawStripes()
  love.graphics.setColor(bgColor[1])
  love.graphics.draw(bgStripes, 0, 0)

  love.graphics.setColor(bgColor[1])
  love.graphics.draw(bgStripes, width, height, 0, -1, -1)
end

function drawLights()
  local originalCanvas = love.graphics.getCanvas()

  bgTime = love.timer.getTime() - bgTimeStart
  love.graphics.setCanvas(lightCanvas)
  love.graphics.clear()
  love.graphics.setColor(1,1,1,math.abs(math.sin(bgTime*lightPace[1]))*lightMax[1]+lightMin[1])
  love.graphics.draw(light1, 0, 0)
  love.graphics.setColor(1,1,1,math.abs(math.sin(bgTime*lightPace[2]))*lightMax[2]+lightMin[2])
  love.graphics.draw(light2, light2:getWidth()/2, light2:getHeight()/2-200, lightAngle[2], 1, 1, light2:getWidth()/2, light2:getHeight()/2)
  love.graphics.setColor(1,1,1,math.abs(math.sin(bgTime*lightPace[3]))*lightMax[3]+lightMin[3])
  love.graphics.draw(light3, light3:getWidth()/2, light3:getHeight()/2-100, lightAngle[3], 1, 1, light3:getWidth()/2, light3:getHeight()/2)
  love.graphics.setColor(1,1,1,math.abs(math.sin(bgTime*lightPace[4]))*lightMax[4]+lightMin[4])
  love.graphics.draw(light4, light4:getWidth()/2-100, light4:getHeight()/2, lightAngle[4], 1, 1, light4:getWidth()/2, light4:getHeight()/2)

  love.graphics.setBlendMode("add")
  love.graphics.setCanvas(originalCanvas)
  love.graphics.setColor(1,1,1,lightsMaxOpacity)
  love.graphics.draw(lightCanvas, 0, 0)
  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(1,1,1,1)
end

function drawBG()
  love.graphics.setColor(bgColor[1])
  love.graphics.rectangle("fill", 0, 0, width, height)

  for i=1, tableLength(bgX), 1 do
    love.graphics.setColor(bgColor[cycleColor(i,tableLength(bgColor))])
    love.graphics.rectangle("fill", 0, bgy+bgGap*(i-1)+bgUnitHeight, width, bgUnitHeight+bgGap)
    love.graphics.draw(bgNeutral,bgX[i], bgy+bgGap*(i-1))
    love.graphics.draw(bgNeutral,bgX[i]+width, bgy+bgGap*(i-1))    
  end

  drawStars()
  drawStripes()
  drawLights()
end

function generateDiededMessages()
  love.graphics.setFont(dedfont)

  diededMessages = {}

  diededMessage1 = love.graphics.newCanvas(width, 108)
  love.graphics.setCanvas(diededMessage1)
  messageText="YOU DIEDED"
  love.graphics.print(messageText, width/2-dedfont:getWidth(messageText)/2, 0)
  table.insert(diededMessages, diededMessage1)

  diededMessage2 = love.graphics.newCanvas(width, 108)
  love.graphics.setCanvas(diededMessage2)
  messageText="DED"
  love.graphics.print(messageText, width/2-dedfont:getWidth(messageText)/2, 0)
  table.insert(diededMessages, diededMessage2)

  diededMessage3 = love.graphics.newCanvas(width, 108)
  love.graphics.setCanvas(diededMessage3)
  messageText="VERY DED"
  love.graphics.print(messageText, width/2-dedfont:getWidth(messageText)/2, 0)
  table.insert(diededMessages, diededMessage3)

  diededMessage4 = love.graphics.newCanvas(width, 108)
  love.graphics.setCanvas(diededMessage4)
  messageText="WASTED"
  love.graphics.print(messageText, width/2-dedfont:getWidth(messageText)/2, 0)
  table.insert(diededMessages, diededMessage4)

  diededMessage5 = love.graphics.newCanvas(width, 108)
  love.graphics.setCanvas(diededMessage5)
  messageText="REKT"
  love.graphics.print(messageText, width/2-dedfont:getWidth(messageText)/2, 0)
  table.insert(diededMessages, diededMessage5)

  diededMessage6 = love.graphics.newCanvas(width, 108)
  love.graphics.setCanvas(diededMessage6)
  messageText="ULTRA DED"
  love.graphics.print(messageText, width/2-dedfont:getWidth(messageText)/2, 0)
  table.insert(diededMessages, diededMessage6)

  diededMessage7 = love.graphics.newCanvas(width, 108)
  love.graphics.setCanvas(diededMessage7)
  messageText="DEADFUL"
  love.graphics.print(messageText, width/2-dedfont:getWidth(messageText)/2, 0)
  table.insert(diededMessages, diededMessage7)

  diededMessage8 = love.graphics.newCanvas(width, 108)
  love.graphics.setCanvas(diededMessage8)
  messageText="INCREDIBLY DED"
  love.graphics.print(messageText, width/2-dedfont:getWidth(messageText)/2, 0)
  table.insert(diededMessages, diededMessage8)

  diededMessage9 = love.graphics.newCanvas(width, 108)
  love.graphics.setCanvas(diededMessage9)
  messageText="NOT LIVING"
  love.graphics.print(messageText, width/2-dedfont:getWidth(messageText)/2, 0)
  table.insert(diededMessages, diededMessage9)

  diededMessage10 = love.graphics.newCanvas(width, 108)
  love.graphics.setCanvas(diededMessage10)
  messageText="WELCOME TO DIE"
  love.graphics.print(messageText, width/2-dedfont:getWidth(messageText)/2, 0)
  table.insert(diededMessages, diededMessage10)

  love.graphics.setCanvas()
  love.graphics.setFont(font)
end

-------COPIED BY P END----------



-- Load resources
function love.load()
  love.graphics.reset( )
  math.randomseed(os.time())
  love.window.setFullscreen(true, "desktop")
  desktopWidth, desktopHeight, flags = love.window.getMode( )
  width, height = 1920, 1080
  xs = desktopWidth/width
  ys = desktopHeight/height
  font = love.graphics.newFont(14)
  platformInstance = Platform(10, 150, 150, 50, xs, ys)
  itemsInstance = {}
  scoreTicksInstance = {}
  heroInstance = Hero(35, -96, 400, 96, 117)
  scoreInstance = Score(width/2-50, 10)
  controllersInstace = Controllers(width/2-50, height/2)
  generationTime = 0

  -- Vignette stuff
  width, height = 1920, 1080
  dedSize, dedBorder, dedTime = 200, 20, 2
  dedPosition = height/2-dedSize
  dedBlur, dedOpacity = 1, 0.5
  dedMove = 30
  ded = false
  -- Blur shader stuff
  horizontalShader = nil
  verticalShader = nil
  canvasA, canvasB, canvasC = nil, nil, nil
  -- BG colours
  bgColor = {
    rgb(255,190,51),--1
    rgb(247,182,49),--2
    rgb(240,173,48),--3
    rgb(229,161,46),--4
    rgb(225,156,45)--5
  }
  -- BG coordinates
  bgX = {0,-120,-480,0, -120,-480,0,-120}
  bgVX = {300,100,200,400, 500,300,200,400}
  bgy, bgGap = -100, 150--135
  bgUnitHeight = 0
  -- Light values
  lightGeneralPace = 3
  lightPace = {0.05*lightGeneralPace,0.09*lightGeneralPace,0.11*lightGeneralPace,0.07*lightGeneralPace}
  lightMax = {0.8,0.05,0.8,0.7}
  lightMin = {0.05,0,0.1,0}
  lightsMaxOpacity = 0.8
  lightAngle = {0,0.1,0,0.1}
  -- Star values
  starRows = 8
  starColumns = 24
  starX, starY = -190, -160
  starRowX = {0,0,0,0, 0,0,0,0}
  starPaddingX, starPaddingY = 200, 150
  starVX = {150,250,200,100, 50,150,200,100}
  starRotation = 0
  starVRotation = 0.5
  starRotationCoefficientX, starRotationCoefficientY = 0.3, 0.3

  --bg images
  bgNeutral = love.graphics.newImage("bg/bg-neutral.png")
  bgStripes = love.graphics.newImage("bg/stripes.png")
  bgUnitHeight = bgNeutral:getHeight()

  light1 = love.graphics.newImage("bg/light1.png")
  light2 = love.graphics.newImage("bg/light2.png")
  light3 = love.graphics.newImage("bg/light3.png")
  light4 = love.graphics.newImage("bg/light4.png")
  --bgVignette = love.graphics.newImage("bg/vignette.png")
  bgStar = love.graphics.newImage("bg/star.png")
  starDeadline = bgStar:getWidth()*1.05+starPaddingX

  lightCanvas = love.graphics.newCanvas()
  starCanvas = love.graphics.newCanvas()
  
  bgTimeStart = love.timer.getTime() + 20*1000*1000

  roughEffect = love.graphics.newImage("assets/roughEffect.png")

  dedfont = love.graphics.newImageFont("assets/dedfont.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZ")
  generateDiededMessages()

  --sound
  if aliveBGM == nil then
    aliveBGM = love.audio.newSource("assets/sound/alive2.ogg", "stream")
    dedBGM = love.audio.newSource("assets/sound/ded2.ogg", "stream")
    dedChord = love.audio.newSource("assets/sound/dedchord.wav", "static")
  end

  aliveBGM:setLooping(true)
  aliveBGM:play()
  aliveBGM:setVolume(0.7)
  dedBGM:setLooping(true)
  dedBGM:play()
  dedBGM:setVolume(0)

----COPIAR AQUI TAMBÉM--initializeDed aqui
  initializeDed()

----COPIAR AQUI TAMBÉM--morrer instantâneamente para testar xD
  --die()
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
  scoreInstance:update(dt)
  controllersInstace:update(dt)
  removeItemsOutOfWorld()
  computeGameOver()
  generateRandomItems(dt)
  updateResult = love.timer.getTime() - updateStart

  animateBG(dt)

end

-- All drawing comes here
function love.draw()
  drawStart = love.timer.getTime()
  love.graphics.scale(xs, ys)

  drawDedBefore()

  drawBG()

  love.mouse.setVisible(false)
  platformInstance:draw()
  heroInstance:draw()
  for i, item in ipairs(itemsInstance) do
    item:draw()
  end
  for i, scoreTick in ipairs(scoreTicksInstance) do
    scoreTick:draw()
  end

  scoreInstance:draw()
  controllersInstace:draw(ded)

  --depois de desenhar tudo, efeito legal
  drawRoughEffect()

----COPIAR AQUI TAMBÉM--depois de tudo, drawDedAfter
  drawDedAfter()

  --love.graphics.setFont(dedfont)
  --love.graphics.print("DED", 300, 400)
  --love.graphics.setFont(font)

  drawResult = love.timer.getTime() - drawStart
  --drawUpdateDrawBars()
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

function love.keypressed(key, scancode, isrepeat)
  if key == "return" and ded then
    love.load()
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

function updateScore(removed, dt)
  for i, item in ipairs(removed) do
    scoreInstance:updateScore(item)
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
    die()
  end
end

local itemTypes = {
  Item.itemTypes.good,
  Item.itemTypes.good,
  Item.itemTypes.good,
  Item.itemTypes.good,
  Item.itemTypes.good,
  Item.itemTypes.good,
  Item.itemTypes.bad,
  Item.itemTypes.bad,
  Item.itemTypes.bad,
  Item.itemTypes.gooder
}
function generateRandomItems(dt)
  generationTime = generationTime + dt
  if generationTime > 1 then
    generationTime = 0
    local itemHeight, itemWidth = 57, 93
    local itemType = itemTypes[math.random(#itemTypes)]
    local itemPositionY = itemHeight + math.random(height - itemHeight)
    local itemPositionX = width
    if itemType == Item.itemTypes.gooder then
      itemPositionX = itemWidth + math.random(width - itemWidth)
    end
    table.insert(itemsInstance, Item(itemPositionX, itemPositionY, itemWidth, itemHeight, itemType))
  end
end
