local vec = require 'vendor.brinevector-master.brinevector'
-- Standing state
-- Possible input: left, right - change angle
-- Possible input: up - accelerate
PStateDefault = {
  name = "default"
}

function PStateDefault:update(player, dt)
  
  local turnLeft = love.keyboard.isDown(player.controlTurnLeft)
  local turnRight = love.keyboard.isDown(player.controlTurnRight)
  local accelerate = love.keyboard.isDown(player.controlAccelerate)
  

  if turnLeft then
    player.angle = player.angle - (5 * dt)
  elseif turnRight then
    player.angle = player.angle + (5 * dt)
  end

  if accelerate then          
      player.currentSpeedMultiplicator = player.maxSpeedMultiplicator
      player.acceleration = vec(math.sin(player.angle), - math.cos(player.angle))      
  end

end