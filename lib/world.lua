local vec = require 'vendor.brinevector-master.brinevector'
require 'lib.HUD'
require 'lib.obstacles-ring'
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
  players = {}
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
  ObstaclesRing:update(dt)
  World:updatePlayers(dt)
  ObstaclesRing:CheckCollisions()
  Food:CheckCollisions()
end

function World:addPlayer(player)
  table.insert(self.players, player)
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

function World:keypressed(key)
  if key == 'escape' then
    love.event.push('quit')
  end
  love.keyboard.keysPressed[key] = true
end

function World:draw()
  if self.gameState == 'running' then
    Food:render()
    ObstaclesRing:render()
    World:renderPlayers()
    HUD:renderPlayerStats()
  else 
    ObstaclesRing:render()
    HUD:renderGameEnd()
  end
end

function World:createActors()  

  -- Create the swirling rings
  ObstaclesRing:init({
    cx = self.winWidthHalf,
    cy = self.winHeightHalf,
    chakraRadius = self.winHeightHalf * 5 / 6
  })
  ObstaclesRing:createObstacles()

  -- Create First foods
  Food:init()
  Food:addOne()

  -- Create the Player
  local fish = Player:new(nil,"Czoko")
  World:addPlayer( fish )

end