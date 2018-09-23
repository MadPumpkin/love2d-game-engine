local ObjectOriented = require ('engine.core.ObjectOriented')
if not ComponentRegistry
  local ComponentRegistry = ObjectOriented.new('ComponentRegistry')
end

ComponentRegistry.register = function(name,component)
  if type(name) == "string" and type(component) == "table" then
    self[name] = component
  else
    error("ComponentRegistry: Key must be a string, value must be a table  (key : "..type(name)..", component : "..type(component)..")")
  end
end

ComponentRegistry.unregister = function(name)
  if self[name] ~= nil then
    self[name] = nil
  end
end

ComponentRegistry.getComponent = function(name)
  if self[name] ~= nil then
    return self[name]
  else
    error("ComponentRegistry: Component not found ("..name..")")
  end
end

if not component_registry_instance
  local component_registry_instance = ComponentRegistry()
end

return component_registry_instance
