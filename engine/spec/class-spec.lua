local class = require 'engine.core.Class'

return function(...)
  if not require 'engine.core.spec.set-spec' then error('Set module specification tests failed') end
  local spec = function(...)
    local class_new_test = class.new()

  end
  return spec(arg)
end
