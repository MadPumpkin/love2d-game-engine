require ('core.vector')

Camera = {}
Camera.__index = Camera

function Camera:create(t)
  local camera = {
    position = Vector:create(),
    offset = Vector:create(),
    zoom = 2,
    target = t
  }
  setmetatable(self, camera)
  return camera
end

function Camera:drawBegin()
  if self.target then
    love.graphics.push()
    love.graphics.scale(self.zoom)
    love.graphics.translate(self.position.x, self.position.y)
  end
end

function Camera:drawEnd()
  if self.target then
    love.graphics.pop()
  end
end

function Camera:transformPoint(x, y)
  local scaled_x, scaled_y = (x * (1/self.zoom)), (y * (1/self.zoom))
  local transformed_x, transformed_y = scaled_x-self.position.x, scaled_y-self.position.y
  return transformed_x, transformed_y
end

function Camera:update(dt)
  if self.target then
    local position = self.target:getComponent("physics"):getPosition()
    local half_width = love.graphics.getWidth()/2
    local half_height = love.graphics.getHeight()/2

    self.offset:set(half_width, half_height)

    self.position:setX( -((position:getX()) - (self.offset:getX() * (1/self.zoom))) )
    self.position:setY( -((position:getY()) - (self.offset:getY() * (1/self.zoom))) )
  end
end
