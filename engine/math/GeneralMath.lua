
function math.mod(a,b) return a - math.floor(a/b)*b end
function math.length(x,y) return math.dist(x,y,x,y) end
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y2, x2-x1) end
function math.round(x) return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5) end
function math.truncate(x,digits)
  local shift = 10 ^ digits
  return math.floor( x*shift + 0.5 ) / shift
end

function math.normal(x1,y1, x2,y2)
  local dx=x2-x1
  local dy=y2-y1

  return -dx, dy
end

function math.dot(x1,y1, x2,y2) return (x1*x2 + y1*y2) end

function math.proj(x1,y1, x2,y2)
  dp = math.dot(x1,y1, x2,y2)

  local x = ( dp / (x2*x2 + y2*y2) ) * x2;
  local y = ( dp / (x2*x2 + y2*y2) ) * y2;

  return x,y
end
