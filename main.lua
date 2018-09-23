local engine = require 'engine.engine'
local Functional = require 'engine.core.Functional'
local ObjectOriented = require 'engine.core.ObjectOriented'
local Set = require 'engine.core.Set'

function love.load()

end

function love.update(dt)

end

function love.draw()
  love.graphics.setBackgroundColor(30, 30, 30)
  love.graphics.setColor(255, 255, 255)


  love.graphics.print(Functional.to_string(engine), 40, 40)
end
