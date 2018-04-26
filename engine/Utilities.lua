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

function table.str(table, depth)
  local tabdepth = depth or 0
  local tabulate = function() return string.rep('\t',depth) end
  local nest = function() depth = depth + 1 ; return tabulate() end
  local unnest = function() depth = depth - 1 ; return tabulate() end

  local result = ''
  for key, value in pairs(table) do
    result = result..nest()..tostring(key)..' : '..tostring(value)..'\n'
    if type(value) == 'table' then
      result = result..table.str(value, depth+1)..'\n'
    else
      result = result..tostring(value)..'\n'
    end
  end
  return result
end
