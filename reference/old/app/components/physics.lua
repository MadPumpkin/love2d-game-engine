require ('core.vector')
require ('core.AABB')

Physics = AABB:create()
Physics.__index = Physics

function Physics:create(x,y,w,h)
  local physics = AABB:create(x,y,w,h)
  setmetatable(physics, self)
  self.__index = self

  physics.velocity = Vector:create()

  return physics
end

function Physics:setVelocity(x, y)
  self.velocity:set(x, y)
end

function Physics:getVelocity()
  return self.velocity:get()
end
