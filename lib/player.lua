local vec = require 'vendor.brinevector-master.brinevector'

-- Standing state
-- Possible input: left, right - change angle
-- Possible input: up - accelerate
PStateDefault = {
  name = "default"
}
function PStateDefault:update(player, dt)
  local keyLeft = love.keyboard.isDown('left')
  local keyRight = love.keyboard.isDown('right')
  local keyUp = love.keyboard.isDown('up')
  if keyLeft then
    player.angle = player.angle - (5 * dt)
  elseif keyRight then
    player.angle = player.angle + (5 * dt)
  end
  if keyUp then
      player.currentSpeedMultiplicator = player.maxSpeedMultiplicator
      player.acceleration.x = math.sin(player.angle)
      player.acceleration.y = - math.cos(player.angle) -- minus because we need to invert the Y axis
  end
end

PStateAccelerating = {
  name = "accelerating"
}
function PStateAccelerating:update(player, dt)
end

Player = {
    name = '',
    position = vec(100, 100),
    lives = 3,
    points = 0,
    angle = 0,
    velocity = vec(0, 0),
    acceleration = vec(0, 0),
    maxSpeedMultiplicator = 100, -- initial Speed multiplicator when starting to accelerate, decreasing on each frame if key not pressed
    currentSpeedMultiplicator = 100,
    speedDamping = 0.994, -- value by which the speedmultiplicator will be multiplied to make the fishy stop eventually
    width = 14,
    height = 14,
    halfW = 7 ,
    halfH = 7,
    state = PStateDefault
}

function Player:new(init, name)
  init = init or {}
  setmetatable(init, self)
  self.__index = self
  self.name = name or 'Fish'
  self.model = {
    0, 0, self.halfW, -self.halfH, self.width, 0
  }
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


function Player:calculateVerticesFromPosition()
  self.vertices = {
    self.model[1] + self.position.x, self.model[2] + self.position.y,
    self.model[3] + self.position.x, self.model[4] + self.position.y,
    self.model[5] + self.position.x, self.model[6] + self.position.y
  }
end

function Player:update(dt)
  self.state:update(self, dt)
  self:reCalculatePosition(dt)
  -- self:calculateVerticesFromPosition()
end

function Player:reCalculatePosition(dt)
  local speed = vec(self.acceleration.x, self.acceleration.y)
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
  self.position.x = World.winWidthHalf
  self.position.y = World.winHeightHalf
  self.velocity = vec(0, 0)
  self.acceleration = vec(0, 0)
  if self.lives < 1 then
    World.gameState = 'out-of-lives'
  end
end

function Player:onEatenFood(planktonIdx)
  self.points = self.points + 1
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
  -- love.graphics.print(self.acceleration.x .. " : " .. self.acceleration.y, self.position.x - self.width, self.position.y - self.height * 2)
  love.graphics.pop()
end
