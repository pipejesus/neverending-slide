HUD = {

}

function HUD:renderGameEnd()
  love.graphics.push()
  love.graphics.translate(World.winWidthHalf, World.winHeightHalf)
  love.graphics.print("Congrats! Your score: " .. World.players[1].points, -80, 0)
  love.graphics.pop()
end

function HUD:renderPlayerStats()
  for index, player in ipairs(World.players) do
    love.graphics.push()
    love.graphics.translate(0, 0)
    love.graphics.print('LIVES: ' .. player.lives)    
    love.graphics.translate(0, 20)
    love.graphics.print('POINTS: ' .. player.points)    
    love.graphics.pop()
  end
end

function HUD:renderDebugCollisions()  
  local collPhraseNOT = "NO!"
  local collPhraseCOLLIDING = "YES!"
  local collPhrase = ""
  if World.colliding == true then
    collPhrase = collPhraseCOLLIDING
  else 
    collPhrase = collPhraseNOT
  end

  love.graphics.print(collPhrase .. World.mouseX .. ":" .. World.mouseY)
end