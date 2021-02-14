
local mlib = require "vendor.mlib.mlib"

function IsPlayerIntersectingSomething(playerPolygon, somethingPolygon)
    return mlib.polygon.getPolygonIntersection(playerPolygon, somethingPolygon)  
end

-- to be changed into simple utility function
-- for interactions between simpler elements
function IsPointInRotatedAABB(pointX, pointY, centerX, centerY, halfW, halfH, angle, playerAngle)
  local lx, ly = pointX - centerX, pointY - centerY
  lx, ly = RotatePoint(lx, ly, angle)
  
  if lx < -halfW or lx > halfW then
    return false
  end

  if ly < -halfH or ly > halfH then
    return false
  end
  
  return true
end

-- Ref: strona 286 "Matematyka dla programistów Java" 
-- ROTATION MATRIX AROUND (centerX, centerY):
-- cos(a)   sin(a)    0
-- -sin(a)  cos(a)    0
--    0       0       1
function RotatePoint(x, y, angle, centerX, centerY)
  x = x - centerX
  y = y - centerY
  local c, s = math.cos(angle), math.sin(angle)  
  local newX, newY = (c * x - s * y), (c*y + s *x)
  newX, newY = newX + centerX , newY + centerY
  return newX, newY
end

function Map(value, start1, stop1, start2, stop2, withinBounds)
  local range1 = stop1 - start1
  local range2 = stop2 - start2
  value = (value - start1) / range1 * range2 + start2
  return withinBounds and math.clamp(value, start2, stop2) or value
end

function HSV(h, s, v)
  if s <= 0 then return v,v,v end
  h, s, v = h/256*6, s/255, v/255
  local c = v*s
  local x = (1-math.abs((h%2)-1))*c
  local m,r,g,b = (v-c), 0,0,0
  if h < 1     then r,g,b = c,x,0
  elseif h < 2 then r,g,b = x,c,0
  elseif h < 3 then r,g,b = 0,c,x
  elseif h < 4 then r,g,b = 0,x,c
  elseif h < 5 then r,g,b = x,0,c
  else              r,g,b = c,0,x
  end return {r = (r+m)*255, g = (g+m)*255, b = (b+m)*255}
end