local Set = require('engine.core.Set')
local Class = require('engine.core.Class')

local EngineObject = Class:new('EngineObject')

EngineObject:setAttribute('children',Set:new())

EngineObject:setAttribute('setup',function(...)
  print('EngineObject.setup()')
end)

EngineObject:setAttribute('shutdown',function()
  print('EngineObject.shutdown()')
end)

EngineObject:setAttribute('update',function(dt)
  print('EngineObject.update()')
end)

EngineObject:setAttribute('draw',function()
  print('EngineObject.draw()')
end)

return EngineObject
