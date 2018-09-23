local ObjectOriented = require ('engine.core.ObjectOriented')
require ('engine.core.AABB')

World = ObjectOriented.new('World')
World.unit_size = { width=16, height=16 }
World.size = { width=22, height=240 }
World.bodies = Set()

function World:update(dt)
  self:resolveIntersections(self.bodies)
end

function World:draw()
  -- TODO add if debug, show collision rectangles
end

function World:addBody(body)
  return self.bodies:add_element(body)
end

function World:removeBody(body_handle)
  return self.bodies:remove_element(body_handle)
end

function World:resolveCollisions()
  for i=1,#self.bodies do
    lhs = self.bodies[i]
    for j=i+1,#self.bodies do
      rhs = self.bodies[j]
      lhs:resolveIntersection(rhs)
    end
  end
end

return World
