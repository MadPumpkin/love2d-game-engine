

function cleanSet(set)
  local ans = {}
  for _,v in pairs(set) do
    ans[ #ans+1 ] = v
  end
  return ans
end

function addToSet(set, key)
    set[key] = true
end

function removeFromSet(set, key)
    set[key] = nil
end

function setContains(set, key)
    return set[key] ~= nil
end
