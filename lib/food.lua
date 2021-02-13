Food = {
  planktonW = 10,
  planktonH = 10,
  planktonHalfW = 5,
  planktonHalfH = 5,
  plankton = {}
}

function Food:init()
  math.randomseed(love.timer.getTime(), love.timer.getTime())
end

function Food:render()
  love.graphics.push()
  love.graphics.setColor(0.1, 0.6, 0.2, 1)
  for index, plankton in ipairs(self.plankton) do
    if plankton.status == 'fresh' then
        love.graphics.rectangle('fill', plankton.cx - self.planktonHalfW, plankton.cy - self.planktonHalfH, self.planktonW, self.planktonH)
    end
  end
  love.graphics.pop()
end

function Food:addOne()
  local cx = math.random(self.planktonW, World.winWidth - self.planktonW)
  local cy = math.random(self.planktonH, World.winHeight - self.planktonH)
  table.insert(self.plankton, {
    status = 'fresh',
    type = 'good',
    cx = cx,
    cy = cy
  })  
end

function Food:getFoodPolygon(plankton)
  local x1, y1, x2, y2, x3, y3, x4, y4
  x1 = plankton.cx - self.planktonHalfW
  y1 = plankton.cy - self.planktonHalfH
  x2 = x1 + self.planktonW
  y2 = y1
  x3 = x1 + self.planktonW
  y3 = y1 + self.planktonH
  x4 = x1
  y4 = y1 + self.planktonH
  return {x1, y1, x2, y2, x3, y3, x4, y4}
end

function Food:removeOne(plankIdx)
  self.plankton[plankIdx].status = 'eaten'
end

function Food:CheckCollisions()  
  for index, plankton in ipairs(self.plankton) do  
    if plankton.status ~= 'eaten' then
      for indexPlayer, player in ipairs(World.players) do        
        if IsPlayerIntersectingSomething(player:getPolygonRotated(), self:getFoodPolygon(plankton)) then        
          player:onEatenFood(index)
        end
      end
    end
  end
end