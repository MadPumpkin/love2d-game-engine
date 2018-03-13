require ('entity')
require ('components')

require ('world')
require ('player')
require ('camera')

function love.load()
  player = Player:create(32, 32)
  camera = Camera:create( player )
  world = World:create(camera, player)

  debug_info = {}
  debug = false
end

function love.update(dt)
  world:update(dt)
  player:update(dt)
  camera:update(dt)
end

function love.draw()
  local mx, my = love.mouse.getX(), love.mouse.getY()
  local transform_x, transform_y = camera:transformPoint(mx, my)
  local tx, ty = world:getTileIndexAtPoint(transform_x, transform_y)


  camera:drawBegin()
  world:draw()
  player:draw()
  if debug then
    love.graphics.rectangle( "line", tx*16, ty*16, 16, 16 )
  end
  camera:drawEnd()
  if debug then
    debug_info[1] = world:getTileAtPoint(transform_x, transform_y)
    debug_info[2] = tostring(mx.." : "..my)
    debug_info[3] = tostring(tx.." : "..ty)
    debug_info[4] = tostring(#player.bullets)
    debug_info[4] = tostring(player.state)
    love.graphics.print(tostring(component_registry), 100, 100 )
    for i=1, #debug_info do
      love.graphics.print(tostring(debug_info[i]), love.graphics.getWidth()-100, 20*i)
    end

    love.graphics.print(tostring(love.timer.getFPS()), 20, love.graphics.getHeight()-24)
  end

  player:drawGUI()

end

function love.keypressed(key)
  world:keypressed(key)
  --player:keypressed(key)
  if key == "y" then
    debug = not debug
  end
end
