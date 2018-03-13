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
  print(tableToString(self))
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
  return self:new(self:filter(self:bind_first(self.contains, self)))
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
  return result
end

function Set:fold_right(method, axiom, ...)
  local result = {}
  for _, key in pairs(self.elements) do
    axiom = method(axiom, key, unpack(...))
  end
  return result
end

function Set:reduce(method, ...)
  return self:fold_right(method, self:head(), self:tail(), unpack(...))
end

function Set:curry(f, g, ...)
  local arguments = unpack(...)
  return function()
    return f(g(arguments))
  end
end

function Set:bind_first(method, first, ...)
  local arguments = unpack(arg)
  return function (second)
    return method(first, second, arguments)
  end
end

function Set:bind_second(method, second, ...)
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
  local step = self:bind_second(self.operator[(from < to) and 'add' or 'sub'], 1)
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

function tableToString(table, depth)
  local tabdepth = depth or 1
  local tabulate = function(n) return string.rep('\t',n) end
  local result = ''
  for key, value in pairs(table) do
    if type(value) == 'table' then
      result = result..tabulate(tabdepth)..tostring(key)..': '..'\n'..tableToString(value, tabdepth+1)
    else
      result = result..tabulate(tabdepth)..tostring(key)..' = '..tostring(value)..'\n'
    end
  end
  return result
end

function Set:__tostring()
  return tableToString(self)
end

return Set
