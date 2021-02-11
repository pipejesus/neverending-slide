require 'lib.u'
require 'lib.world'


love.graphics.setDefaultFilter('nearest', 'nearest')

function love.load()
    -- local o1 = Object:new(nil, {x = 30, y = 50})
    -- local o2 = Object:new(nil, {x = 100, y=120})
    --
    -- print(o1.x .. " : " .. o1.y)
    -- print(o2.x .. " : " .. o2.y)

    World:load()
    -- love.window.setFullscreen( true )
end

function love.resize(w, h)
end

function love.keypressed(key)
    World:keypressed(key)
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    World:update(dt)
end

function love.draw()
    World:draw()
end
