local UnitTestFramework = {}
UnitTestFramework.__index = UnitTestFramework

function UnitTestFramework:new()
  local framework = {

  }
  setmetatable(framework, UnitTestFramework)

  return framework
end
