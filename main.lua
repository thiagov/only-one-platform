function newAnimation(image, width, height, duration)
  local animation = {}
  animation.spriteSheet = image;
  animation.quads = {};

  for y = 0, image:getHeight() - height, height do
    for x = 0, image:getWidth() - width, width do
      table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
    end
  end

  animation.duration = duration or 1
  animation.currentTime = 0

  return animation
end

-- Load resources
function love.load()
  idle_anim = newAnimation(love.graphics.newImage("assets/sprites/idle.png"), 64, 64, 1)
end

-- Called continuously. dt = delta time
function love.update(dt)
  idle_anim.currentTime = idle_anim.currentTime + dt
  if idle_anim.currentTime >= idle_anim.duration then
    idle_anim.currentTime = idle_anim.currentTime - idle_anim.duration
  end
end

-- All drawing comes here
function love.draw()
  -- love.graphics.print("Hello World", 400, 300)
  local spriteNum = math.floor(idle_anim.currentTime / idle_anim.duration * #idle_anim.quads) + 1
  love.graphics.draw(idle_anim.spriteSheet, idle_anim.quads[spriteNum], 0, 0, 0, 4)
end
