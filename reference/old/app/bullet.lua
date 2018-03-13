require ('core.clock')
require ('entity')
require ('components')

Bullet = Entity:create(component_registry)
Bullet.__index = Bullet


function Bullet:create(x,y)
  local bullet = Entity:create(component_registry)
  setmetatable(bullet, self)
  self.__index = self
  bullet:setType("bullet")

  bullet.lifetime = Clock:create(5)
  bullet.lifetime:start()

  bullet:addComponent("physics")
  bullet:getComponent("physics"):setPosition(x,y)
  return bullet
end

function Bullet:update(dt)
  self.lifetime:update(dt)
  if self.lifetime.finished then
    self.active = false
  else
    local physics = self:getComponent("physics")
    physics:setPosition( physics:getPosition() + physics:getVelocity() )
  end
end

function Bullet:draw()
  local physics = self:getComponent("physics")
  love.graphics.setColor(200, 160, 40)
  love.graphics.rectangle( "fill", physics:getPosition():getX()-1, physics:getPosition():getY()-1, 2, 2)
end
