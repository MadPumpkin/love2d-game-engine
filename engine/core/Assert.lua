local Assert = {}
Assert.__index = Assert
Assert.prints = true
Assert.exits = true

function Assert.prints_debug(enabled)
  local debug = enabled or not(Assert.prints)
  Assert.prints = debug
end

function Assert.exits_on_failure(enabled)
  local exits = enabled or not(Assert.exits)
  Assert.exits = exits
end

function Assert.print(string)
  if Assert.prints_debug then
    print(string)
  end
end

function Assert.that(truth, message)
  if Assert.exits then
    assert(truth, message)
  else
    print(message)
    return truth
  end
end

function Assert.method_string(method_name, ...)
  local state_string = 'Assert.'..tostring(method_name)
  for k,v in pairs(arg) do
    state_string = state_string..' <'..tostring(k)..', '..tostring(v)..'>\t'
  end
  return state_string
end

function Assert.equal(a, b, message)
  local method_string = Assert.method_string('equal', a, b, message)
  local equality = (a == b)
  Assert.print(method_string)
  Assert.that(equality, method_string)
  return equality
end

function Assert.not_equal(a, b, message)
  local method_string = Assert.method_string('not_equal', a, b, message)
  local equality = (a ~= b)
  Assert.print(method_string)
  Assert.that(equality, method_string)
  return equality
end

function Assert.less_than(a, b, message)
  local method_string = Assert.method_string('less_than', a, b, message)
  local equality = (a < b)
  Assert.print(method_string)
  Assert.that(equality, method_string)
  return equality
end

function Assert.greater_than(a, b, message)
  local method_string = Assert.method_string('greater_than', a, b, message)
  local equality = (a > b)
  Assert.print(method_string)
  Assert.that(equality, method_string)
  return equality
end

function Assert.less_than_or_equal(a, b, message)
  local method_string = Assert.method_string('less_than_or_equal', a, b, message)
  local equality = (a <= b)
  Assert.print(method_string)
  Assert.that(equality, method_string)
  return equality
end

function Assert.greater_than_or_equal(a, b, message)
  local method_string = Assert.method_string('greater_than_or_equal', a, b, message)
  local equality = (a >= b)
  Assert.print(method_string)
  Assert.that(equality, method_string)
  return equality
end

return Assert
