require ('engine.core.Vector')
require ('engine.core.AABB')

Camera = {}
Camera.__index = Camera


function Camera:create(target)
  local camera = {
    active = false,
    target = target,
    position = Vector:create(),
    offset = Vector:create(),
    zoom = 1.8,
    zoom_minimum = 0.4,
    zoom_maximum = 10,
    zoom_factor = 0.2
  }
  setmetatable(camera, self)
  return camera
end

function Camera:setTarget(target)
  self.target = target
end

function Camera:activate()
  self.active = true
end

function Camera:deactivate()
  self.active = false
end

function Camera:isActive()
  return self.active
end

function Camera:getViewRectangle()
  local top_left_x, top_left_y = self:transformPoint(x, y)
  local bottom_right_x, bottom_right_y = self:transformPoint(love.graphics.getWidth(), love.graphics.getHeight())
  return AABB:create(top_left_x, top_left_y, bottom_right_x, bottom_right_y)
end

function Camera:setZoom(zoom)
  self.zoom = zoom
end

function Camera:getZoom()
  return self.zoom
end

function Camera:zoomIn()
  if self.zoom < self.zoom_maximum then
    self.zoom = self.zoom + self.zoom_factor
  end
end

function Camera:zoomOut()
  if self.zoom > self.zoom_minimum then
    self.zoom = self.zoom - self.zoom_factor
  end
end

function Camera:drawBegin()
  if self:isActive() then
    love.graphics.push()
    love.graphics.scale(self.zoom)
    love.graphics.translate(self.position.x, self.position.y)
  end
end

function Camera:drawEnd()
  if self:isActive() then
    love.graphics.pop()
  end
end

function Camera:transformPoint(x, y)
  local scaled_x, scaled_y = (x * (1/self.zoom)), (y * (1/self.zoom))
  local transformed_x, transformed_y = scaled_x-self.position.x, scaled_y-self.position.y
  return transformed_x, transformed_y
end

function Camera:update(dt)
  if self:isActive() then
    if self.target then
      local position = self.target.position
      local half_width = love.graphics.getWidth()/2
      local half_height = love.graphics.getHeight()/2

      self.offset:set(half_width, half_height)

      self.position:setX( -((position.x) - (self.offset:getX() * (1/self.zoom))) )
      self.position:setY( -((position.y) - (self.offset:getY() * (1/self.zoom))) )
    end
  end
end
