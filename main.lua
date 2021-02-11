require 'lib.u'
require 'lib.world'

love.graphics.setDefaultFilter('nearest', 'nearest')

function love.load()
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
