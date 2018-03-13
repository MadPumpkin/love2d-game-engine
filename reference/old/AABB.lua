
function AABB( x, y, width, height )
  local box =
  {
    x = x, y = y,
    width = width, height = height,

    getLeft = function (self) return self.x end,
    getTop = function (self) return self.y end,
    getRight = function (self) return self.x+self.width end,
    getBottom = function (self) return self.y+self.height end
  }

  return box
end


function PointvsAABB( point, box )
  return box.x <= point.x and point.x <= box.x+box.width and
         box.y <= point.y and point.y <= box.y+box.height
end

isHovering = PointvsAABB

function AABBvsAABB(box_a, box_b)
  if box_a ~= nil and box_b ~= nil then
    return box_a.x < box_b.x+box_b.width and
           box_a.x+box_a.width > box_b.x and
           box_a.y < box_b.y+box_b.height and
           box_a.y+box_a.height > box_b.y
  else
    return nil
  end
end

function GetIntersection(box_a, box_b)
  local intersection = {}

  intersection.x = math.max(box_a.x, box_b.x)
  intersection.y = math.max(box_a.y, box_b.y)
  intersection.width = math.min(box_a.x+box_a.width, box_b.x+box_b.width) - intersection.x
  intersection.height = math.min(box_a.y+box_a.height, box_b.y+box_b.height) - intersection.y

  return intersection
end

function ResolveIntersection(box_a, box_b)
  if AABBvsAABB(box_a, box_b) then
    local intersect = GetIntersection(box_a, box_b)

    if intersect.width < intersect.height then
      if box_a.x > box_b.x then
        box_a.x = box_a.x + intersect.width
      else
        box_a.x = box_a.x - intersect.width
      end
    else
      if box_a.y > box_b.y then
        box_a.y = box_a.y + intersect.height
      else
        box_a.y = box_a.y - intersect.height
      end
    end

  else
    intersect = nil
  end
end
