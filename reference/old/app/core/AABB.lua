require ('core.vector')

AABB = {}
AABB.__index = AABB

function AABB:create(x, y, w, h)
  local box = {
    position = Vector:create(x or 0, y or 0),
    size = Vector:create(w or 0, h or 0)
  }
  setmetatable(box, self)
  self.__index = self
  return box
end

function AABB:set( x, y, w, h)
  self.position:set(x,y)
  self.size:set(w,h)
end

function AABB:setPosition(x, y)
  self.position:set(x, y)
end

function AABB:setSize(width, height)
  self.size:set(width, height)
end

function AABB:getPosition()
  return self.position:get()
end

function AABB:getSize()
  return self.size:get()
end

function AABB:getTop()
  return self.position.y
end

function AABB:getLeft()
  return self.position.x
end

function AABB:getRight()
  return self.position.x+self.size.x
end

function AABB:getBottom()
  return self.position.y+self.size.y
end

function AABB:getWidth()
  return self.size.x
end

function AABB:getHeight()
  return self.size.y
end

function AABB:contains(vector)
  if self:getLeft() < vector.x and vector.x < self:getRight() then
    if self:getTop() < vector.y and vector.y < self:getBottom() then
      return true
    end
  end
  return false
end

function AABB:collides(rhs)
  return (self:getLeft() < rhs:getRight() and
          self:getRight() > rhs:getLeft() and
          self:getTop() < rhs:getBottom() and
          self:getBottom() > rhs:getTop())
end

function AABB:getIntersection(rhs)
  local intersection = nil
  if self:collides(rhs) then
    local intersect_x = math.max(self.position.x, rhs.position.x)
    local intersect_y = math.max(self.position.y, rhs.position.y)
    intersection = self:create( intersect_x,
                                intersect_y,
                                math.min(self:getRight(), rhs:getRight()) - intersect_x,
                                math.min(self:getBottom(), rhs:getBottom()) - intersect_y
                              )
  end
  return intersection
end

-- detect and solve for self
function AABB:resolveIntersection(rhs)
  local intersect = self:getIntersection(rhs)

  if intersect then
    if intersect:getWidth() < intersect:getHeight() then
      if self.position.x > rhs.position.x then
        self.position.x = self.position.x + intersect:getWidth()
      else
        self.position.x = self.position.x - intersect:getWidth()
      end
    else
      if self.position.y > rhs.position.y then
        self.position.y = self.position.y + intersect:getHeight()
      else
        self.position.y = self.position.y - intersect:getHeight()
      end
    end
  end
end
