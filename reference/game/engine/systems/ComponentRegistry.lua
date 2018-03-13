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
