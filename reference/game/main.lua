--[[ ENGINE ]]
require ('engine.Engine')
--[[ GAME ]]
require ('WorldGenerator')


function love.load()
  success = love.window.setMode( 800, 600, { resizable=true } )

  camera_target = {
    position = {
      x = 0,
      y = 0
    }
  }

  engine = Engine:create()
  engine.Scene.active_camera:setTarget(camera_target)
  world_generator = WorldGenerator:create(engine)
  world_generator:generate()
end

function love.update(dt)
  engine:update(dt)
  if love.keyboard.isDown('w') then
    camera_target.position.y = camera_target.position.y - 30
  elseif love.keyboard.isDown('s') then
    camera_target.position.y = camera_target.position.y + 30
  end
  if love.keyboard.isDown('a') then
    camera_target.position.x = camera_target.position.x - 30
  elseif love.keyboard.isDown('d') then
    camera_target.position.x = camera_target.position.x + 30
  end
end

function love.draw()
  engine:draw()
  love.graphics.print('#maps:\t'..tostring(#engine.Scene.maps), 80, 16)
  love.graphics.print('size:\t\t'..tostring(#production), 80, 32)
  love.graphics.print('output:\t'..tostring(production), 80, 48)
end

function love.keypressed(key)
  if key == "space" then
    world_generator:generate()
  end
end

function love.wheelmoved( x, y )
  if math.sign(y) > 0 then
    engine.Scene.active_camera:zoomIn()
  elseif math.sign(y) < 0 then
    engine.Scene.active_camera:zoomOut()
  end
end
