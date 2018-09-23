function math.lerp(P, Q, interpolant)
  return {
    x=((1 - interpolant.x) * P.x + interpolant.x * Q.x),
    y=((1 - interpolant.y) * P.y + interpolant.y * Q.y)
  }
end

function math.sign(value)
  if value > 0 then
    return 1
  elseif value == 0 then
    return 0
  else
    return -1
  end
end
