-- Vignette stuff
width, height = 1920, 1080
dedSize, dedBorder, dedTime = 200, 20, 2
dedPosition = height/2-dedSize
dedBlur, dedOpacity = 0.3, 0.5
dedMove = 30
ded = false

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


-- Blur shader stuff
horizontalShader = nil
verticalShader = nil
canvasA, canvasB, canvasC = nil, nil, nil

function gaussianSquared(x, size)
   local radius = size/2
   local sigma = radius
   local value = (1/(sigma*math.sqrt(2*math.pi)))
      * math.exp((-x*x)/(2*sigma*sigma))
   return value*value
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

function normalize(weights)
   local sum = 0
   for i,v in ipairs(weights) do
      sum = sum + v
   end
   for i,v in ipairs(weights) do
      weights[i] = v*(1/sum)
   end
end

function generateBlurWeights(number)
   local weights = {}
   for i = 1, number+1 do
      weights[i] = gaussianSquared((i-1) - number/2, number)
   end
   normalize(weights)
   local sum = 0
   for i,v in ipairs(weights) do
      sum = sum + v
   end
   print("sum: " .. tostring(sum) .. " (should be 1)")
   
   local substitutionString = ""
   -- pixelColor += Texel(currentTexture, vBlurOffsets[13])*0.0044299121055113265;
   local index = 0
   local inserted = false
   local stepsize = 1
   for i = 0,number,1 do
      if index+1 > number/2 and not inserted then
   substitutionString = substitutionString .. "pixelColor += Texel(currentTexture, texCoords       )*".. tostring(weights[number/2]) ..";\n"
   inserted = true
      else
   -- note that this expression uses both "i" and "index"
   substitutionString = substitutionString .. "pixelColor += Texel(currentTexture, vBlurOffsets[" .. tostring(index) .."])*" .. tostring(weights[i+1]) .. ";\n"
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
   
   print(horizontalVertexSource)
   print(verticalVertexSource)
   
   local fragmentSource = love.filesystem.read("material.fsh")
   fragmentSource = fragmentSource:gsub("${{GENERATE_BLUR_WEIGHTINGS}}", generateBlurWeights(blurSamples))
   fragmentSource = fragmentSource:gsub("${{NUM_BLUR_SAMPLES}}", blurSamples)
   print(fragmentSource)
   
   horizontalShader = love.graphics.newShader(horizontalVertexSource, fragmentSource)
   verticalShader = love.graphics.newShader(verticalVertexSource, fragmentSource)
   print(horizontalShader:getWarnings())
   print(verticalShader:getWarnings())
end


function die()
  dedStart = love.timer.getTime()
end


function initializeDed()
  dieded = love.graphics.newImage("ded.png")
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
    love.graphics.setCanvas(canvasA)
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
    --love.graphics.draw(canvasC, quadful, 0, dedPosition)  
  





    love.graphics.setColor(1, 1, 1, math.min(dedOpacity*dedFinish/dedTime, dedOpacity))
    love.graphics.draw(vignetteLove, 0, dedPosition)

    love.graphics.draw(dieded, width/2-dieded:getWidth()/2, dedPosition+dedSize/2-dieded:getHeight()/1.75+math.max(dedMove-dedMove*dedFinish/dedTime, 0))
    love.graphics.setColor(1, 1, 1, 1)
  end
end


----------COPIAR ATÉ AQUI--------------


-- Load resources
function love.load()
  love.window.setMode(width, height, {fullscreen=true, fullscreentype="exclusive"})
  desktopWidth, desktopHeight, flags = love.window.getMode( )

  image = love.graphics.newImage("walk100x150.png")
  font = love.graphics.newFont(14)
  love.mouse.setVisible(false)


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

  roughEffect = love.graphics.newImage("roughEffect.png")

----COPIAR AQUI TAMBÉM--initializeDed aqui
  initializeDed()

----COPIAR AQUI TAMBÉM--morrer instantâneamente para testar xD
  die()
end

-- Called continuously. dt = delta time
function love.update(dt)
  updateStart = love.timer.getTime()

  animateBG(dt)

  updateResult = love.timer.getTime() - updateStart
end

-- All drawing comes here
function love.draw()
  drawStart = love.timer.getTime()
  --love.graphics.scale(desktopWidth/width, desktopHeight/height)

----COPIAR AQUI TAMBÉM--drawDedBefore antes de desenhar qualquer coisa
  drawDedBefore()

  --desenha qualquer coisa
  love.graphics.setColor(0.2, 0.5, 0)
  love.graphics.rectangle("fill", 0, 0, width, height)
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(image, 200, 270)

  drawBG()

  --depois de desenhar tudo, efeito legal
  drawRoughEffect()

----COPIAR AQUI TAMBÉM--depois de tudo, drawDedAfter
  drawDedAfter()

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


function rgb(r, g, b, a)
  if not a then a=1 end
  return {r/255, g/255, b/255, a}
end

function rgba(rgbcolor,a)
  return {rgbcolor[1],rgbcolor[2],rgbcolor[3],a}
end

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