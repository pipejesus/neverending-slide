RingStateDefault = {
  name="default"
}

-- New Ring configuration:
-- cx, cy: center x, y
-- divisions: number of elements in the ring
-- behaviour: static, rotating,
-- movement: normal, growing-shrinking
-- radius: radius of the ring if behaviour:static, behaviour:rotating; the starting radius if behaviour:growing-shrinking
-- minRadius, maxRadius
-- isGrowing: if behaviour:growing-shrinking - whether to start as "growing" (true) or shrinking (false)
-- shrinkingSpeed, growingSpeed: how fast the ring should shrink/grow
-- rotationDirection: 1: clockwise, -1: anti-clockwise

Ring = {
  name = "Ring",
  cx = 0,
  cy = 0,
  divisions = 6,
  behaviour = "static",
  movement = "normal",
  radius = 100,
  minRadius = 1,
  maxRadius = 1,
  isGrowing = true,
  shrinkingSpeed = 15,
  growingSpeed = 15,
  rotationDirection = 1,
  rotationSpeed = 0.25,

  _currentRadius = 1,
  _angleStep = 1,  
  _obstacles = {},
}

local PI_2 = math.pi * 2

function Ring:new(init, setup)
  init = init or {}
  setmetatable(init, self)
  self.__index = self
  for k,v in pairs(setup) do init[k] = v end
  init._angleStep = (math.pi * 2) / setup.divisions
  init._currentRadius = setup.radius
  init._obstacles = {}
  -- print(init.radius)
  return init
end

function Ring:createObstacles()
  print(self._obstacles)
  local currentAngle = math.rad(0)
  for i = 1, self.divisions do
    local obstacleCx = self.cx + math.cos(currentAngle) * self.radius
    local obstacleCy = self.cy + math.sin(currentAngle) * self.radius
    table.insert(self._obstacles, {
      cx = obstacleCx,
      cy = obstacleCy,
      w = 20,
      h = 80,
      wHalf = 10,
      hHalf = 40,
      angle = currentAngle,
      colliding = false,
    })
    currentAngle = currentAngle + self._angleStep
  end
end

function Ring:Update(dt)
  -- print(self.radius)
  if self.movement == "growing-shrinking" then
    self:UpdateObstaclesGrowingShrinking(dt)
  end
  if self.behaviour == "rotating" then
    self:UpdateObstaclesRotation(dt)
  end
end

function Ring:UpdateObstaclesGrowingShrinking(dt)
  if self._currentRadius > self.maxRadius then
    self.isGrowing = false
    self._currentRadius = self.maxRadius - 1
  elseif self._currentRadius < self.minRadius then
    self.isGrowing = true
    self._currentRadius = self.minRadius
  end

  if self.isGrowing == true then
    self._currentRadius = (self._currentRadius + (self.growingSpeed * dt))
  else
    self._currentRadius = (self._currentRadius - (self.shrinkingSpeed * dt))
  end
end

function Ring:UpdateObstaclesRotation(dt)
  local deltaAngle = self.rotationDirection * self.rotationSpeed
  for index, obstacle in ipairs(self._obstacles) do
    obstacle.angle = ( obstacle.angle + deltaAngle * dt) % PI_2
    obstacle.cx = self.cx + math.cos(obstacle.angle) * self._currentRadius
    obstacle.cy = self.cy + math.sin(obstacle.angle) * self._currentRadius
  end
end

function Ring:Render()
  if self._obstacles == nil then
    return
  end

  for index, obstacle in ipairs(self._obstacles) do
    if obstacle.colliding == true then
      love.graphics.setColor( 0.5, 0.3, 0.3, 1)
    else
      love.graphics.setColor( 0.3, 0.3, 0.3, 1)
    end
    love.graphics.push('all')
    love.graphics.translate(obstacle.cx, obstacle.cy)
    love.graphics.rotate( - math.atan2( obstacle.cy - self.cy, self.cx - obstacle.cx) )
    love.graphics.translate(-obstacle.cx, -obstacle.cy)
    love.graphics.rectangle('fill', obstacle.cx - obstacle.wHalf, obstacle.cy - obstacle.hHalf, obstacle.w, obstacle.h)
    love.graphics.pop()
    love.graphics.setColor( 1, 1, 0, 1 )
  end
end

function Ring:CheckCollisions()
  local foundColliding = false
  if self._obstacles == nil then
    return
  end

  for index, obstacle in ipairs(self._obstacles) do
    if IsBoundingBoxInRotatedAABB(World.players[1]:getBoundingBox(), obstacle.cx, obstacle.cy, obstacle.wHalf, obstacle.hHalf, obstacle.angle) then
      obstacle.colliding = true
      foundColliding = true
      World.players[1]:onCollided()
    else
      obstacle.colliding = false
    end
  end
  World.colliding = foundColliding
end
