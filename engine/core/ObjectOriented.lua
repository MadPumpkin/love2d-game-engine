local Functional = require('engine.core.Functional')

local ObjectOriented = {}
local ObjectRegistry = {}
ObjectOriented.__index = ObjectOriented
ObjectOriented.next_id = 0
ObjectOriented.instance_meta = {
  __call = function(object) return ObjectOriented.instance(object) end,
  __index = function(object, key) return ObjectOriented.get_attribute(object, key) end,
  __newindex = function(object, key, value) return ObjectOriented.set_attribute(object, key, value) end,
  instance_of = function(object, type) return ObjectOriented.is_instance(object, type) end,
  subclass = ObjectOriented.subclass
}
ObjectOriented.instance_meta.__index = ObjectOriented.instance_meta
setmetatable(ObjectOriented.instance_meta, ObjectOriented)


function ObjectOriented.__next_id()
  local id = ObjectOriented.next_id
  ObjectOriented.next_id = ObjectOriented.next_id + 1
  return id
end

function ObjectOriented.is_object(table)
  if type(table) == 'table' then
    return table['__classtype'] ~= nil
  end
  return nil
end

function ObjectOriented.new(class_name)
  if class_name and type(class_name) == 'string' then
    local class = {
      __classid = ObjectOriented.__next_id(),
      __classtype = true,
      class_name = class_name,
      attributes = {},
      superclasses = {},
      subclasses = {}
    }
    setmetatable(class, ObjectOriented.instance_meta)
    ObjectRegistry[class.class_name] = class
    return class
  else
    --[[TODO: Replace with Expect]]
    error('Error in ObjectOriented.new(class_name, ...) : class_name invalid')
    return nil
  end
end

function ObjectOriented.subclass(base, class_name)
  local type = ObjectOriented.new(class_name)
  setmetatable(type, ObjectOriented.instance_meta)
  type:add_superclass(base)
  type.attributes = Functional.join(base.attributes, type.attributes, true)
  return type
end

function ObjectOriented.add_superclass(base, superclass)
  if ObjectOriented.is_object(base) and ObjectOriented.is_object(superclass) then
    base.superclasses[#base.superclasses+1] = ObjectOriented.name(superclass)
    superclass.subclasses[#superclass.subclasses+1] = ObjectOriented.name(base)
    return true
  end
  return nil
end

function ObjectOriented.add_subclass(base, subclass)
  ObjectOriented.add_superclass(subclass, base)
end

function ObjectOriented.identity(class)
  return class.__classid
end

function ObjectOriented.name(class)
  return class.class_name
end

function ObjectOriented.instance(class)
  local instance = Functional.shallow_clone(class)
  instance.attributes = Functional.shallow_clone(class.attributes)
  instance.subclasses = Functional.shallow_clone(class.subclasses)
  instance.superclasses = Functional.shallow_clone(class.superclasses)
  setmetatable(instance, ObjectOriented.instance_meta)
  return instance
end

function ObjectOriented.is_instance(object, type)
  return (object.__classid == type.__classid)
end

function ObjectOriented.get_attribute(object, key)
  if ObjectOriented.is_object(object) then
    local instance_attribute = object.attributes[key]
    if not instance_attribute then
      for k,v in pairs(object.superclasses) do
        instance_attribute = ObjectOriented.get_attribute(ObjectRegistry[v], key)
        if instance_attribute then
          return instance_attribute
        end
      end
    end
    return instance_attribute
  else
    error('ObjectOriented.get_attribute(object, key) object was not of object type')
    return nil
  end
end

function ObjectOriented.set_attribute(object, key, value)
  object.attributes[key] = value
  return object.attributes[key]
end

return ObjectOriented
