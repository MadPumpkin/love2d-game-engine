local Functional = {}
Functional.__index = Functional


Functional.operator = {
    mod = math.mod,
    pow = math.pow,
    add = function(n,m) return n + m end,
    sub = function(n,m) return n - m end,
    mul = function(n,m) return n * m end,
    div = function(n,m) return n / m end,
    gt  = function(n,m) return n > m end,
    lt  = function(n,m) return n < m end,
    eq  = function(n,m) return n == m end,
    le  = function(n,m) return n <= m end,
    ge  = function(n,m) return n >= m end,
    ne  = function(n,m) return n ~= m end
}

function Functional.to_string(table, depth)
  local tabdepth = depth or 0
  local tabulate = function() return string.rep('\t',tabdepth) end
  local nest = function() tabdepth = tabdepth + 1 ; return tabulate() end
  local unnest = function() tabdepth = tabdepth - 1 ; return tabulate() end

  local result = ''
	if type(table) == 'table' then
	  for key, value in pairs(table) do
      -- result = result..tabulate()..'<'..tostring(type(value))..'> '
	    if type(value) == 'table' then
	      result = result..tabulate()..tostring(key)..' : {'

        if tabdepth+1 > 0 then
    	     result = result..'\n'
         end
        result = result..Functional.to_string(value, tabdepth+1)
        result = result..tabulate()..'}\n'
	    else
        result = result..tabulate()..tostring(key)..' : '..Functional.to_string(value)..'\n'
      end
	  end
	elseif type(table) == 'string' then
		result = result..tabulate()..table
  else
    result = result..tostring(table)
	end
  return result
end

-- Target table and it's elements are cloned
function Functional.shallow_clone(set)
	local clone
	if type(set) == 'table' then
		clone = {}
		for k,v in pairs(set) do
			clone[k] = v
		end
	else
		clone = set
	end
	return clone
end

-- Target table is cloned recursively including the metatable
function Functional.deep_clone(set)
	local clone
	if type(set) == 'table' then
		clone = {}
		for k, v in next, set, nil do
			clone[Functional.deep_clone(k)] = Functional.deep_clone(v)
		end
		setmetatable(clone, Functional.deep_clone(getmetatable(set)))
	else
		clone = set
	end
	return clone
end

function Functional.clone(set)
	return Functional.deep_clone(set)
end

function Functional.join(set, other, hard_join, ...)
	local joined = Functional.clone(set)
	for k, v in pairs(other) do
		if hard_join then
			joined[k] = v
		else
			if not set[k] then
				joined[k] = v
			end
		end
	end
	if arg ~= nil then
		for i=1,#arg do
			joined = Functional.join(joined, arg[i], hard_join)
		end
	end
	return joined
end

function Functional.reverse(set)
	local reversed = Functional.clone(set)
	local left, right = 1, #reversed
	while left < right do
    reversed[left], reversed[right] = reversed[right], reversed[left]
		left = left + 1
		right = right - 1
	end
	return reversed
end

function Functional.invert(set)
	local result = {}
	for k,v in pairs(set) do
		result[v] = k
	end
	return result
end

function Functional.contains_value(set, value)
	return Functional.invert(set)[value] ~= nil
end

function Functional.find_value(set, value)
	return Functional.invert(set)[value]
end

function Functional.map(set, method, ...)
 local result = {}
 for key, element in pairs(set) do
   result[key] = method(element, ...)
 end
 return result
end

function Functional.filter(set, method, ...)
  local result = {}
  for key, element in pairs(set) do
    if method(element, unpack(...)) then
      result[#result+1] = element
    end
  end
  return result
end

function Functional.fold_right(set, method, initial_value, ...)
  local value = initial_value or 0
  for _, key in pairs(set) do
    value = method(value, key, unpack(...))
  end
  return value
end

function Functional.fold_left(set, method, initial_value, ...)
  return Functional.fold_right(Functional.reverse(set), method, initial_value or 0, ...)
end

function Functional.accumulate(set, method, ...)
	return Functional.fold_right(set, method, 0, ...)
end

function Functional.reduce(set, method, ...)
	return Functional.fold_left(set, method, 0, ...)
end

function Functional.curry(f, g, ...)
	local arguments = unpack(...)
	return function()
		return f(g(arguments))
	end
end

function Functional.bind_first(method, first, ...)
	local arguments = unpack(arg)
	return function(second)
		return method(first, second, arguments)
	end
end

function Functional.bind_second(method, second, ...)
	local arguments = unpack(arg)
	return function(first)
		return method(first, second, arguments)
	end
end

function Functional.expand(method, ...)
  return function(...) return method(...) end
end

function Functional.clean(set)
	return Functional.clone(Functional.filter(Functional.bind_first(Functional.contains_value, set)))
end

return Functional
