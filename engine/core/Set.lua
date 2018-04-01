local Set = {}
Set.__index = Set

function Set:new(table)
  local set = {
    elements = {}
  }
  setmetatable(set, Set)

  if type(table) == 'table' then
    for k, v in pairs(table) do
      set:add(k,v)
    end
  end
  return set
end

function Set:__index(element)
  if self.elements[element] then
    return self.elements[element]
  else
    return Set[element]
  end
end

function Set:flatten()
  return self.elements
end

function Set:joined(other)
  local joined = Set:new(self:flatten())
  for element, value in pairs(other:flatten()) do
    joined:add(element, value)
  end
  print(self:stringify())
  return joined
end

function Set:join(other)
  self = self:joined(other)
end

function Set:head()
  return self.elements[1]
end

function Set:tail()
  return self.elements[#self.elements+1]
end

function Set:inverted()
  local result = {}
  for key, element in pairs(self.elements) do
    result[element] = key
  end
  return result
end

function Set:cleaned()
  return self:new(self:filter(self:bindFirst(self.contains, self)))
end

function Set:clean()
  self = self:cleaned()
end

function Set:contains(element)
  return self:inverted()[element] ~= nil
end

function Set:firstOccurence(element)
  return self:inverted()[element]
end

function Set:add(element, value)
  if value ~= nil then
    self.elements[element] = value
  else
    self:push(element)
  end
  return self.elements[element]
end

function Set:remove(element)
  if self:contains(element) then
    self.elements[self:firstOccurence(element)] = nil
    self:clean()
  end
  return self.elements[element]
end

function Set:push(element)
  self.elements[#self.elements+1] = element
  return self.elements[element]
end

function Set:pop()
  local result = self:tail()
  self.elements[#self.elements] = nil
  return result
end

function Set:map(method, ...)
  local result = {}
  for key, element in pairs(self.elements) do
    result[key] = method(element, ...)
  end
  return result
end

function Set:filter(method, ...)
  local result = {}
  for key, element in pairs(self.elements) do
    if method(element, unpack(arg)) then
      result[#result+1] = element
    end
  end
  return Set:new(result)
end

function Set:foldRight(method, axiom, ...)
  local result = {}
  for _, key in pairs(self.elements) do
    axiom = method(axiom, key, unpack(...))
  end
  return result
end

function Set:reduce(method, ...)
  return self:foldRight(method, self:head(), self:tail(), unpack(...))
end

function Set:curry(f, g, ...)
  local arguments = unpack(...)
  return function()
    return f(g(arguments))
  end
end

function Set:bindFirst(method, first, ...)
  local arguments = unpack(arg)
  return function (second)
    return method(first, second, arguments)
  end
end

function Set:bindSecond(method, second, ...)
  local arguments = unpack(...)
  return function (first)
    return method(first, second, arguments)
  end
end

function Set:expect(method, expected, ...)
  local arguments = unpack(...)
  return function ()
    if(method(arguments) == expected) then
      return true
    else
      return false
    end
  end
end

Set.operator = {
    mod = math.mod;
    pow = math.pow;
    add = function(n,m) return n + m end;
    sub = function(n,m) return n - m end;
    mul = function(n,m) return n * m end;
    div = function(n,m) return n / m end;
    gt  = function(n,m) return n > m end;
    lt  = function(n,m) return n < m end;
    eq  = function(n,m) return n == m end;
    le  = function(n,m) return n <= m end;
    ge  = function(n,m) return n >= m end;
    ne  = function(n,m) return n ~= m end;
}

function Set:range(from, to)
  local result = {}
  local step = self:bindSecond(self.operator[(from < to) and 'add' or 'sub'], 1)
  local element = from
  while element <= to do
    result[#result+1] = element
    element = step(element)
  end
  return result
end

function Set:expand(method, ...)
  return function(...) return method(...) end
end

function Set:__unittest()
  if require 'core.spec.set-spec' then
    return true -- TODO return some_unit_test_pass_message
  else
    return nil, 'spec.set-spec did not pass, "set" module not imported'
  end
end

function Set:stringify(depth)
  local tabdepth = depth or 0
  local tabulate = function() return string.rep('\t',tabdepth) end
  local nest = function() tabdepth = tabdepth + 1 ; return tabulate() end
  local unnest = function() tabdepth = tabdepth - 1 ; return tabulate() end

  local result = ''
  for key, value in pairs(self.elements) do
    result = result..nest()..tostring(key)..' : '..tostring(value)..'\n'
    if type(value) == 'table' then
      result = result..self:stringify(value, tabdepth+1)..'\n'
    else
      result = result..tostring(value)..'\n'
    end
  end
  return result
end

function Set:__tostring()
  return self:stringify()
end

return Set
