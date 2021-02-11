local vec = require 'vendor.brinevector-master.brinevector'
require 'lib.HUD'
-- require 'lib.obstacles-ring'
require 'lib.ring'
require 'lib.player'
require 'lib.food'

World = {
  winWidth = 640,
  winHeight = 480,
  winWidthHalf = 0,
  winHeightHalf = 0,
  colliding = false,
  diamonds = {},
  gameState = 'running',
  players = {},
  enemies = {}
}

function World:load()
  love.window.setTitle('Neverending Slide')
  love.window.setMode(self.winWidth, self.winHeight)
  love.keyboard.keysPressed = {}
  self:initVars()
  self:createActors()
end

function World:initVars()
  self.winWidthHalf = self.winWidth / 2
  self.winHeightHalf = self.winHeight / 2
end

function World:update(dt)
  love.keyboard.keysPressed = {}
  World:updateEnemies(dt) -- ObstaclesRing:update(dt)
  World:updatePlayers(dt)
  World:checkEnemiesCollisions() -- ObstaclesRing:CheckCollisions()
  Food:CheckCollisions()
end

function World:addEnemy(enemy)
  table.insert(self.enemies, enemy )
end

function World:addPlayer(player)
  table.insert(self.players, player)
end

function World:checkEnemiesCollisions()
  for index, enemy in ipairs(self.enemies) do
    enemy:CheckCollisions()
  end
end

function World:updateEnemies(dt)
  for index, enemy in ipairs(self.enemies) do
    -- print(enemy.name)
    enemy:Update(dt)
  end
end

function World:updatePlayers(dt)
  for index, player in ipairs(self.players) do
    player:update(dt)
  end
end

function World:renderPlayers()
  for index, player in ipairs(self.players) do
    player:render()
  end
end

function World:renderEnemies()
  for index, enemy in ipairs(self.enemies) do
    enemy:Render()
  end
end

function World:keypressed(key)
  if key == 'escape' then
    love.event.push('quit')
  end
  love.keyboard.keysPressed[key] = true
end

function World:draw()
  if self.gameState == 'running' then
    Food:render()
    World:renderEnemies() -- ObstaclesRing:render()
    World:renderPlayers()
    HUD:renderPlayerStats()
  else
    World:renderEnemies()
    HUD:renderGameEnd()
  end
end

function World:createActors()

  -- Create the swirling rings
  local ring1 = Ring:new(nil, {
    name = "Ring 1",
    cx = self.winWidthHalf,
    cy = self.winHeightHalf,
    divisions = 6,
    behaviour = "rotating",
    movement = "normal",
    radius = 200,
    minRadius = 100,
    maxRadius = 200,
    isGrowing = true,
    shrinkingSpeed = 20,
    growingSpeed = 45,
    rotationDirection = 1,
    rotationSpeed = 0.25,
  })
  ring1:createObstacles()

  local ring2 = Ring:new(nil, {
    name = "Ring 2",
    cx = self.winWidthHalf,
    cy = self.winHeightHalf,
    divisions = 4,
    behaviour = "rotating",
    movement = "normal",
    radius = 100,
    minRadius = 50,
    maxRadius = 100,
    isGrowing = true,
    shrinkingSpeed = 20,
    growingSpeed = 45,
    rotationDirection = -1,
    rotationSpeed = 0.65,
  })
  ring2:createObstacles()


  World:addEnemy(ring1)
  World:addEnemy(ring2)

  print(ring1.name)
  print(ring2.name)

  -- World:addEnemy()

  -- ObstaclesRing:init({
  --   cx = self.winWidthHalf,
  --   cy = self.winHeightHalf,
  --   chakraRadius = self.winHeightHalf * 5 / 6
  -- })
  -- ObstaclesRing:createObstacles()

  -- Create First foods
  Food:init()
  Food:addOne()

  -- Create the Player
  local fish = Player:new(nil, "Czoko")
  World:addPlayer( fish )

end
