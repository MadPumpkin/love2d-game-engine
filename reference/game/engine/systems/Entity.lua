--[[ Entity ]]


Entity = {}
Entity.__index = Entity

function isEntity(o)
  return getmetatable(o) == Entity
end

function Entity:create(registry)
  local entity = {
    type = "entity",
    active = true,
    registry = registry,
    components = {}
  }
  setmetatable( entity, self )
  self.__index = self
  return entity
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

function Entity:execute(name, command, ...)
  local component = self:getComponent(name)
  if component[command] ~= nil then
    component[command](component, ...)
  else
    error("Entity: Command not found ("..name.." : "..command..")")
  end
end

function Entity:dispatch(command, ...)
  for k,v in pairs(self.components) do
    if self.components[k][command] ~= nil then
      self.components[k][command](self.components[k], ...)
    end
  end
end
