local vec = require 'vendor.brinevector-master.brinevector'
require 'lib.player-states.player-state-default'
Player = {
    name = '',
    state = PStateDefault,
    velocity = vec(0, 0),
    acceleration = vec(0, 0),
    position = vec(100, 100),
    lives = 5,
    points = 0,
    angle = 0,
    maxSpeedMultiplicator = 100, -- initial Speed multiplicator when starting to accelerate, decreasing on each frame if key not pressed
    currentSpeedMultiplicator = 100,
    speedDamping = 0.994, -- value by which the speedmultiplicator will be multiplied to make the fishy stop eventually
    initialWidth = 14,
    initialHeight = 14,
}

function Player:new(init)
  init = init or {}
  setmetatable(init, self)
  self.__index = self
  self.width = self.initialWidth
  self.height = self.initialHeight
  self.halfW = self.initialWidth / 2
  self.halfH = self.initialHeight /2

  return init
end

-- x1, y1: TOP LEFT
-- x2, y2: TOP RIGHT
-- x3, y3: BOTTOM RIGHT
-- x4, y4: BOTTOM LEFT
function Player:getBoundingBox()
  local x1, y1, x2, y2, x3, y3, x4, y4
  x1 = self.position.x - self.halfW
  y1 = self.position.y - self.halfH
  x2 = x1 + self.width
  y2 = y1
  x3 = x1 + self.width
  y3 = y1 + self.height
  x4 = x1
  y4 = y1+ self.height
  return {
    {x1, y1},
    {x2, y2},
    {x3, y3},
    {x4, y4}
  }
end

function Player:getPolygonRotated()
  local x1, y1, x2, y2, x3, y3, x4, y4
  x1 = self.position.x - self.halfW
  y1 = self.position.y - self.halfH
  x2 = x1 + self.width
  y2 = y1
  x3 = x1 + self.width
  y3 = y1 + self.height
  x4 = x1
  y4 = y1+ self.height
  x1, y1 = RotatePoint(x1, y1, self.angle, self.position.x, self.position.y)
  x2, y2 = RotatePoint(x2, y2, self.angle, self.position.x, self.position.y)
  x3, y3 = RotatePoint(x3, y3, self.angle, self.position.x, self.position.y)
  x4, y4 = RotatePoint(x4, y4, self.angle, self.position.x, self.position.y)
  return {x1, y1, x2, y2, x3, y3, x4, y4}
end

function Player:update(dt)
  self.state:update(self, dt)
  self:reCalculatePosition(dt)  
end

function Player:reCalculatePosition(dt)
  local speed = self.acceleration
  if self.currentSpeedMultiplicator > 0 then
    self.currentSpeedMultiplicator = self.currentSpeedMultiplicator - (self.maxSpeedMultiplicator - self.maxSpeedMultiplicator * self.speedDamping)
  end

  speed = speed * dt * self.currentSpeedMultiplicator
  self.position = self.position + speed
  self.position.x = self.position.x % World.winWidth
  self.position.y = self.position.y % World.winHeight
end

function Player:onCollided()
  self.lives = self.lives - 1
  self.points = 0
  self.position.x = World.winWidthHalf
  self.position.y = World.winHeightHalf
  self.velocity = vec(0, 0)
  self.acceleration = vec(0, 0)
  self:resetSize()
  if self.lives < 1 then
    World.gameState = 'out-of-lives'
  end
end

function Player:enlarge()
  self.width = self.width + 2
  self.height = self.height + 2
  self.halfW = self.width / 2
  self.halfH = self.height / 2
end

function Player:resetSize()
  self.width = self.initialWidth
  self.height = self.initialHeight
  self.halfW = self.width / 2
  self.halfH = self.height / 2
end

function Player:onEatenFood(planktonIdx)
  self.points = self.points + 1
  self:enlarge()
  Food.plankton[planktonIdx].status = 'eaten'
  Food:addOne()
end

function Player:render()
  love.graphics.setColor(0.4, 0.4, 0, 1);
  love.graphics.push()
  love.graphics.translate(self.position.x, self.position.y)
  love.graphics.rotate(self.angle)
  love.graphics.translate(-self.position.x, -self.position.y)
  love.graphics.rectangle('fill', self.position.x - self.halfW, self.position.y - self.halfH, self.width, self.height)
  love.graphics.setColor(0.8, 0.8, 0, 1)
  love.graphics.points(
    self.position.x - self.halfW + 4, self.position.y - self.halfH + 3,
    self.position.x + self.halfW - 4, self.position.y - self.halfH + 3
  )
  love.graphics.pop()
end
