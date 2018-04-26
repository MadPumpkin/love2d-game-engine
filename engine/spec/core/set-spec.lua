set = require 'core.set'


return function()
  local numbers = set:new({
    100, 100, 200, 100, 150, 200, 3333, 3, 3,3, 5, 8, 13, 21, 34, 55, 89, 144
  })

  local expected = {
    evens = { 100, 100, 200, 100, 150, 200, 8, 34, 144 },
    odds = { 3333, 3, 3, 3, 5, 8, 13, 21, 55, 89 }
  }

  local is_even = function(n)
    return numbers:bind_second(math.mod, 2)(n) == 0
  end
  local is_odd = function(n)
    return not is_even(n)
  end

  local evens = numbers:filter(is_even)
  local odds = numbers:filter(is_odd)

  for i,v in pairs(numbers.elements) do
    assert(numbers:expect(numbers:filter(is_even) == expected.evens))
    assert(numbers:expect(numbers:filter(is_odd) == expected.odds))
  end
end()
