ObstaclesRing = {
  cx = 0,
  cy = 0,
  chakraRadius = 0,
  currentChakraRadius = 0,
  obstacles = {}
}

function ObstaclesRing:init(init)
  self.cx = init.cx
  self.cy = init.cy
  self.chakraRadius = init.chakraRadius  
  self.currentChakraRadius = init.chakraRadius
end

function ObstaclesRing:createObstacles()
  local angleStepCount = 6
  local angleStep = (math.pi * 2) / angleStepCount
  local currentAngle = math.rad(180)
  for i = 1, angleStepCount do  
    local obstacleCx = self.cx + math.cos(currentAngle) * self.chakraRadius
    local obstacleCy = self.cy + math.sin(currentAngle) * self.chakraRadius
    table.insert(self.obstacles, {
      cx = obstacleCx,
      cy = obstacleCy, 
      w = 20,
      h = 80,
      angle = currentAngle,
      colliding = false,
    })
    currentAngle = currentAngle + angleStep
    -- currentAngle = (math.pi * 2) % ( currentAngle + angleStep)
  end
end

function ObstaclesRing:render()
  for index, obstacle in ipairs(self.obstacles) do
    if obstacle.colliding == true then
      love.graphics.setColor( 0.5, 0.3, 0.3, 1)
    else
      love.graphics.setColor( 0.3, 0.3, 0.3, 1)
    end
    love.graphics.push('all')
    love.graphics.translate(obstacle.cx, obstacle.cy)    
    love.graphics.rotate( - math.atan2( obstacle.cy - ObstaclesRing.cy, ObstaclesRing.cx - obstacle.cx) )
    love.graphics.translate(-obstacle.cx, -obstacle.cy)
    love.graphics.rectangle('fill', obstacle.cx - obstacle.w / 2, obstacle.cy - obstacle.h / 2, obstacle.w, obstacle.h)
    love.graphics.pop()
    love.graphics.setColor( 1, 1, 0, 1)    
    -- love.graphics.print( math.ceil(math.deg( obstacle.angle)), obstacle.cx, obstacle.cy)
  end
end

function ObstaclesRing:update(dt)
  ObstaclesRing:updateObstaclesRotation(dt)
end

function ObstaclesRing:updateObstaclesRotation(dt)  
  -- self.currentChakraRadius = (self.currentChakraRadius - (15 * dt))
  for index, obstacle in ipairs(self.obstacles) do    
    obstacle.angle = ( obstacle.angle + (0.25) * dt) % (math.pi * 2) 
    local obstacleCx = self.cx + math.cos(obstacle.angle) * self.currentChakraRadius
    local obstacleCy = self.cy + math.sin(obstacle.angle) * self.currentChakraRadius
    obstacle.cx = obstacleCx
    obstacle.cy = obstacleCy
  end
end

function ObstaclesRing:CheckCollisions()
  local foundColliding = false
  for index, obstacle in ipairs(self.obstacles) do  
    if IsBoundingBoxInRotatedAABB(World.players[1]:getBoundingBox(), obstacle.cx, obstacle.cy, obstacle.w / 2, obstacle.h / 2, obstacle.angle) then
      obstacle.colliding = true
      foundColliding = true
      World.players[1]:onCollided()
    else
      obstacle.colliding = false
    end
  end
  World.colliding = foundColliding
end
