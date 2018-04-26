local Functional = require ('engine.core.functional')
local Assert = require ('engine.core.assert')

local Expect = {}
Expect.operator = {
  equal = true,
  not_equal = true,
  less_than = true,
  greater_than = true,
  less_than_or_equal = true,
  greater_than_or_equal = true
}

Assert.exits_on_failure(false)
Assert.prints_debug(false)

function Expect.pass_string(a, b, what)
  return '[PASS]\t'..tostring(a)..' '..tostring(what)..' '..tostring(b)..'\n'
end

function Expect.fail_string(a, b, what)
  return '[FAIL]\tExpected '..tostring(a)..' and '..tostring(b)..' to be '..tostring(what)..'\n'
end

function Expect.to_string(a, b, what, pass)
  if pass then
    return Expect.pass_string(a, b, what)
  else
    return Expect.pass_string(a, b, what)
  end
end

Expect.__call = function(table, first)
  local chain = {
    to_be = {}
  }
  setmetatable(chain.to_be, {
    __call = function(table, operator)
      Assert.prints_debug(false)
      if type(operator) == 'boolean' then
        return Assert.equal(first, operator)
      else
        if Expect.operator[operator] ~= nil then
          local second_chain = {
            to = {}
          }
          setmetatable(second_chain.to, {
            __call = function(table, second)
              local equality = Assert[operator](first, second)
              Assert.prints_debug(true)
              equality = Assert[operator](first, second, Expect.to_string(first, second, operator, equality))
              Assert.prints_debug(false)
              return equality
            end
          })
          return second_chain
        else
          error('Expect.operator[\''..Functional.to_string(operator)..'\'] is not a valid operator')
        end
      end
    end
  })
  return chain
end

setmetatable(Expect, Expect)

if not Expect(true).to_be('equal').to(true) or Expect(true).to_be(true) then
  return Expect
else
  error('An unexpected error occurred from within the Expect module')
  return nil
end
