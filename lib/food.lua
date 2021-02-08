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

function Food:removeOne(plankIdx)
  self.plankton[plankIdx].status = 'eaten'
end

function Food:CheckCollisions()  
  for index, plankton in ipairs(self.plankton) do  
    if plankton.status ~= 'eaten' then
      if IsBoundingBoxInRotatedAABB(World.players[1]:getBoundingBox(), plankton.cx, plankton.cy, Food.planktonHalfW, Food.planktonHalfH, 0) then      
        World.players[1]:onEatenFood(index)
      end
    end
  end  
end