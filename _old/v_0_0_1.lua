require 'lib.u'
require 'lib.world'

love.graphics.setDefaultFilter('nearest', 'nearest')
Angle = 0
Speed = 2
SpeedC = 40
CalcSpeed = 0
MovDir = 1
CA, CS, CV = 180, 50, 1

function love.load()
    love.window.setTitle('SS Snake')
    love.window.setMode(World.gameW, World.gameH)
    World.init()    
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.push('quit')
    end
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    love.keyboard.keysPressed = {}
    CA = CA + (SpeedC * dt)    
    CalcSpeed = (Speed * dt) * MovDir    
    Angle = (Angle + CalcSpeed)    
    Angle = Angle % (math.pi * 2)

    if MovDir == 1 and Angle >= math.pi - (math.pi / 8) then          
        MovDir = -1
    elseif MovDir == -1 and Angle >= math.pi * 2 - (math.pi / 8)  then        
        MovDir = 1
    end

    print(math.deg( Angle))
    X = World.gameW / 2 + math.cos(Angle) * World.gameW /2
    Y = World.gameH / 2 + (math.sin(Angle)) * 100
end

function love.draw()     
    for y = 0, World.gameH, 1 do
        local r,g,b = HSV(
            Map(y, 0, World.gameH, 20, 60), 
            170,
            1
        )
        for x = 0, World.gameW do
           love.graphics.setColor(r,g,b,1)
           love.graphics.points(x,y) 
        end        
    end
    local r,g,b = HSV(CA, CS, CV)
    love.graphics.setColor(r,g,b, 1)
    love.graphics.circle('fill', X, Y, 20)
    -- love.graphics.setColor(1,1,1,1)
    love.graphics.points(X, Y)
end