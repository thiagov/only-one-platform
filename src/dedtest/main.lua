-- Vignette stuff
width, height = 1920, 1080
dedSize, dedBorder, dedTime = 200, 20, 2
dedPosition = height/2-dedSize
dedBlur, dedOpacity = 0.3, 0.5
dedMove = 30
ded = true

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
    quadful = love.graphics.newQuad(0, position-1+i, width, 1, width, height)
    love.graphics.draw(drawable, quadful, 0, position-1+i)

    quadful = love.graphics.newQuad(0, position+size-i, width, 1, width, height)
    love.graphics.draw(drawable, quadful, 0, position+size-i)
  end

  quadful = love.graphics.newQuad(0, position+border, width, size-border*2, width, height)
  love.graphics.draw(drawable, quadful, 0, position+border)
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
  roughEffect = love.graphics.newImage("roughEffect.png")
  dedShader = love.graphics.newShader("ded.lua")

  loadShader()
  canvasA, canvasB, canvasC = love.graphics.newCanvas(), love.graphics.newCanvas(), love.graphics.newCanvas()

  vignetteLove = generateVignette(dedSize, dedBorder)
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

    quadful = love.graphics.newQuad(0, dedPosition, width, dedSize, width, height)
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

----COPIAR AQUI TAMBÉM--initializeDed aqui
  initializeDed()

----COPIAR AQUI TAMBÉM--morrer instantâneamente para testar xD
  die()

end

-- Called continuously. dt = delta time
function love.update(dt)
  updateStart = love.timer.getTime()
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
