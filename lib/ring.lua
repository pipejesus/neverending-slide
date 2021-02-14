local mlib = require "vendor.mlib.mlib"
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
  obstacleW = 0,
  obstacleH = 0,
  obstacleShade = HSV(20, 20, 100),
  _currentRadius = 1,
  _angleStep = 1,  
  _obstacles = {},
}

local PI_2 = math.pi * 2

RingObstacle = {
  wHalf = 0,
  hHalf = 0,  
  colorR = 0,
  colorG = 0,
  colorB = 0
}

function RingObstacle:new(init)
  init = init or {}
  setmetatable(init, self)
  self.__index = self
  init.wHalf = init.w / 2
  init.hHalf = init.h / 2
  init.state = RingObstacleStateDefault
  return init
end

RingObstacleStateDefault = {
  name = "default",
  render = function(obstacle, host)
    love.graphics.setColor(obstacle.colorR,obstacle.colorG,obstacle.colorB, 1)
    love.graphics.push('all')
    love.graphics.translate(obstacle.cx, obstacle.cy)
    love.graphics.rotate( - math.atan2( obstacle.cy - host.cy, host.cx - obstacle.cx) )
    love.graphics.translate(-obstacle.cx, -obstacle.cy)
    love.graphics.rectangle('fill', obstacle.cx - obstacle.wHalf, obstacle.cy - obstacle.hHalf, obstacle.w, obstacle.h)
    love.graphics.pop()  
  end
}

RingObstacleStateArmed = {
  name = "armed",
  render = function(obstacle, host)
    love.graphics.setColor(obstacle.colorR + 30,obstacle.colorG,obstacle.colorB, 1)
    love.graphics.push('all')
    love.graphics.translate(obstacle.cx, obstacle.cy)
    love.graphics.rotate( - math.atan2( obstacle.cy - host.cy, host.cx - obstacle.cx) )
    love.graphics.translate(-obstacle.cx, -obstacle.cy)
    love.graphics.rectangle('fill', obstacle.cx - obstacle.wHalf, obstacle.cy - obstacle.hHalf, obstacle.w, obstacle.h)
    love.graphics.pop()      
  end
}

function Ring:new(init, setup)
  init = init or {}
  setmetatable(init, self)
  self.__index = self
  for k,v in pairs(setup) do init[k] = v end
  init._angleStep = (math.pi * 2) / setup.divisions
  init._currentRadius = setup.radius
  init._obstacles = {}  
  return init
end

function Ring:createObstacles()  
  local currentAngle = math.rad(0)
  for i = 1, self.divisions do
    local obstacleCx = self.cx + math.cos(currentAngle) * self.radius
    local obstacleCy = self.cy + math.sin(currentAngle) * self.radius    
    -- table.unpack(self.obstacleShade)
    
    table.insert(self._obstacles, RingObstacle:new({
      cx = obstacleCx,
      cy = obstacleCy,
      w = self.obstacleW,
      h = self.obstacleH,
      angle = currentAngle,
      colorR = self.obstacleShade.r,
      colorG = self.obstacleShade.g,
      colorB = self.obstacleShade.b
    }))
    currentAngle = currentAngle + self._angleStep
  end
end

function Ring:Update(dt)  
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

function Ring:getObstaclePolygon(obstacle)
  local x1, y1, x2, y2, x3, y3, x4, y4
  x1 = obstacle.cx - obstacle.wHalf
  y1 = obstacle.cy - obstacle.hHalf
  x2 = x1 + obstacle.w
  y2 = y1
  x3 = x1 + obstacle.w
  y3 = y1 + obstacle.h
  x4 = x1
  y4 = y1+ obstacle.h
  x1, y1 = RotatePoint(x1, y1, obstacle.angle, obstacle.cx, obstacle.cy)
  x2, y2 = RotatePoint(x2, y2, obstacle.angle, obstacle.cx, obstacle.cy)
  x3, y3 = RotatePoint(x3, y3, obstacle.angle, obstacle.cx, obstacle.cy)
  x4, y4 = RotatePoint(x4, y4, obstacle.angle, obstacle.cx, obstacle.cy)
  return {x1, y1, x2, y2, x3, y3, x4, y4}
end

function Ring:Render()
  if self._obstacles == nil then
    return
  end
  for index, obstacle in ipairs(self._obstacles) do
    obstacle.state.render(obstacle, self)
  end
end

-- DUMMY FOR NOW, NEEDS MORE AGGRESIVE CALCULATION
-- BUT WE MIGHT KEEP IT SIMPLE BECAUSE IT WOULD MEAN REALLY LOTS OF CALCULATIONS
function Ring:CheckAndUpdateObstacleState(obstacle, playersPositions)
  -- local dx = obstacle.cx - playerPosition.x
  -- local dy = obstacle.cy - playerPosition.y
  -- local dist =  (dx * dx + dy * dy)

  local anyNear = false
  for index, playerPosition in ipairs(playersPositions) do
    local dist = mlib.line.getLength(obstacle.cx, obstacle.cy, playerPosition.x, playerPosition.y)  
    if dist < 100 then
      anyNear = true
      break
    end
  end

  if anyNear == true then
    if obstacle.state.name ~= 'armed' then
      obstacle.state = RingObstacleStateArmed
    end
  else
    if obstacle.state.name ~= 'default' then
      obstacle.state = RingObstacleStateDefault
    end
  end

end

function Ring:CheckCollisions()
  
  if self._obstacles == nil then
    return
  end

  for index, obstacle in ipairs(self._obstacles) do
    local playersPositions = {}
    for indexPlayerx, player in ipairs(World.players) do
      local playerPolygon = player:getPolygonRotated()
      local obstaclePolygon = self:getObstaclePolygon(obstacle)      
      if IsPlayerIntersectingSomething(playerPolygon, obstaclePolygon) then        
        player:onCollided()
      end
      table.insert(playersPositions, player.position)      
    end
    
    self:CheckAndUpdateObstacleState(obstacle, playersPositions)

  end
  
end
