local function isVector(v)
	return (
    type(v) == 'table' and
    type(v.x) == 'number' and
    type(v.y) == 'number'
  )
end

Vector = {}
Vector_mt = { __index = Vector,
  __unm = function (lhs)
    return setmetatable({x=-lhs.x,y=-lhs.y}, Vector_mt)
  end,
  __add = function (lhs, rhs)
    assert(isVector(lhs) and isVector(rhs), "__add: wrong argument types (<vector> was expected, type was: "..type(rhs).." (..tostring(rhs)..))")
    return setmetatable({x = lhs.x + rhs.x, y = lhs.y + rhs.y}, Vector_mt)
  end,
  __sub = function (lhs, rhs)
    assert(isVector(lhs) and isVector(rhs), "__sub: wrong argument types (<vector> was expected, type was: "..type(rhs).." ("..tostring(rhs).."))")
    return setmetatable({x = lhs.x - rhs.x, y = lhs.y - rhs.y}, Vector_mt)
  end,
  __eq = function (lhs, rhs)
    return (lhs.x == rhs.x and lhs.y == rhs.y)
  end,
  __lt = function (lhs, rhs)
    return (lhs.x < rhs.x and lhs.y < rhs.y)
  end,
  __le = function (lhs, rhs)
    return (lhs.x <= rhs.x and lhs.y <= rhs.y)
  end,
  __gt = function (lhs, rhs)
    return (lhs.x > rhs.x and lhs.y > rhs.y)
  end,
  __ge = function (lhs, rhs)
    return (lhs.x >= rhs.x and lhs.y >= rhs.y)
  end,
}

function Vector:create(x, y)
	return setmetatable({x=x or 0, y=y or 0}, Vector_mt)
end

function Vector:set(x,y)
  if(type(x)=="table" and y == nil) then
    self.x=x[1]
    self.y=x[2]
  else
    assert(type(x)=="number" and type(y)=="number")
    self.x = x
    self.y = y
  end
end

function Vector:get()
  return self:create(self.x, self.y)
end

function Vector:getX()
  return self.x
end

function Vector:getY()
  return self.y
end

function Vector:setX(x)
  assert(type(x)=="number")
  self.x = x
end

function Vector:setY(y)
  assert(type(y)=="number")
  self.y = y
end

Vector.getWidth = Vector.getX
Vector.getHeight = Vector.getY
Vector.setWidth = Vector.setX
Vector.setHeight = Vector.setY
