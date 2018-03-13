require ('engine.core.AABB')

World = {}
World.__index = World

function World:create()
  local world = {
    unit_size = { width=16, height=16 },
    size = { width=22, height=240 },
    bodies = {}
  }
  setmetatable(world, self)
  self.__index = self
  return world
end

function World:update(dt)
  --TODO separate broadphase and narrow phase, then only resolve narrowed groups
  self:resolveIntersections(self.bodies)
end

function World:draw()

end

function World:addBody(body)
  self.bodies[#self.bodies+1] = body
end

function World:resolveIntersections(body_group)
  for i=1,#body_group do
    lhs_entity = body_group[i]
    for j=i+1,#body_group do
      rhs_entity = body_group[j]
      lhs_entity:resolveIntersection(rhs_entity)
    end
  end
end
