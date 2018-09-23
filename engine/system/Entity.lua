local ObjectOriented = require ('engine.core.ObjectOriented')

Entity = ObjectOriented.new('Entity')
Entity.type = "entity"
Entity.active = true
Entity.registry = nil
Entity.components = {}

function isEntity(o)
  return getmetatable(o) == Entity
end

function Entity:setType(type)
  self.type = type
end

function Entity:getType()
  return self.type
end

function Entity:addComponent(name)
  if self.registry ~= nil then
    if type(name) == "string" then
      local component = self.registry:getComponent(name)
      self.components[name] = component:create()
    end
  else
    error("Entity: No registry associated, component not added ("..name..")")
  end
end

function Entity:hasComponent(name)
  if self.components[name] ~= nil then
    return true
  else
    return false
  end
end

function Entity:getComponent(name)
  if self.components[name] ~= nil then
    return self.components[name]
  else
    error("Entity: Component not found ("..name..")")
  end
end

function Entity:executeCommand(name, command, ...)
  local component = self:getComponent(name)
  if component[command] ~= nil then
    component[command](component, ...)
  else
    error("Entity: Command not found ("..name.." : "..command..")")
  end
end

function Entity:dispatchCommand(command, ...)
  for k,v in pairs(self.components) do
    if self.components[k][command] ~= nil then
      self.components[k][command](self.components[k], ...)
    end
  end
end
