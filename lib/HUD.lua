HUD = {

}

function HUD:renderGameEnd()
  love.graphics.push()
  love.graphics.translate(World.winWidthHalf, World.winHeightHalf)
  for index, player in ipairs(World.players) do
    love.graphics.translate(-30, (index - 1) * 20)
    love.graphics.print(player.name .. ": " .. player.points, 0, 0)
  end
  love.graphics.pop()
end

function HUD:renderPlayerStats()
  for index, player in ipairs(World.players) do
    love.graphics.push()
    love.graphics.translate(0, (index - 1) * 20)
    love.graphics.print(player.name .. ' H: ' .. player.lives .. ' P: ' .. player.points .. ' ' .. player.controlTurnLeft .. " " .. player.controlTurnRight .. " " .. player.controlAccelerate)          
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
end