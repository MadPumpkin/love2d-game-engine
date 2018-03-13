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

function Entity:type()
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

function Entity:componentCommand(command, ...)
  for k,v in pairs(self.components) do
    if self.components[k][command] ~= nil then
      self.components[k][command](self.components[k], ...)
    end
  end
end


--[[ ComponentRegistry ]]

ComponentRegistry = {}
ComponentRegistry.__index = ComponentRegistry

function ComponentRegistry:create()
  local registry = {}
  setmetatable( registry, self)
  self.__index = self
  return registry
end

function ComponentRegistry:register(name,component)
  if type(name) == "string" and type(component) == "table" then
    self[name] = component
  else
    error("ComponentRegistry: Key must be a string, value must be a table  (key : "..type(name)..", component : "..type(component)..")")
  end
end

function ComponentRegistry:unregister(name)
  if self[name] ~= nil then
    self[name] = nil
  end
end

function ComponentRegistry:getComponent(name)
  if self[name] ~= nil then
    return self[name]
  else
    error("ComponentRegistry: Component not found ("..name..")")
  end
end

function ComponentRegistry:__tostring()
  local str = ""
  for k,v in pairs(self) do
    str = str.."\n"..tostring(k.." : ")
    if type(v) == "table" then
      str = str.."{\n"
      for i,j in pairs(self[k]) do
        str = str.."\t"..tostring(i).." = "..tostring(j)..",\n"
      end
      str = str.."}\n"
    end
  end
  return str
end
