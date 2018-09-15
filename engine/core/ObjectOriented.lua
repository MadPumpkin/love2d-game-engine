local Functional = require('engine.core.Functional')

local ObjectOriented = {}
if not ObjectRegistry then
  ObjectRegistry = {}
end
ObjectOriented.__index = ObjectOriented
ObjectOriented.next_id = 0
ObjectOriented.instance_meta = {
  __call = function(object) return ObjectOriented.instance(object) end,
  __index = function(object, key) return ObjectOriented.get_attribute(object, key) end,
  __newindex = function(object, key, value) return ObjectOriented.set_attribute(object, key, value) end,
  -- instance_of = function(object, type) return ObjectOriented.is_instance(object, type) end,
  -- subclass = function(base, class_name) return ObjectOriented.subclass(base, class_name) end
}
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

function ObjectOriented.assert_object(object)
  if ObjectOriented.is_object(object) then
    return true
  else
    error('Error in ObjectOriented.assert_object(object) : object was not of object type')
    return nil
  end
end

function ObjectOriented.same_type(object, type)
  return (object.__classid == type.__classid)
end

function ObjectOriented.is_instance(object)
  return ObjectOriented.is_object(object) and object.__isinstance
end

function ObjectOriented.is_type(object)
  return ObjectOriented.is_object(object) and not object.__isinstance
end

function ObjectOriented.instance_of(object, type)
  if ObjectOriented.assert_object(object) and ObjectOriented.assert_object(type) then
    local object_is_instance = ObjectOriented.is_instance(object)
    local type_is_type = not (ObjectOriented.is_instance(type))
    if ObjectOriented.same_type(object, type) then
      return object_is_instance and type_is_type
    end
  else
    error('Error in ObjectOriented.instance_of(object, type) : Only objects can be instances of type objects')
    return nil
  end
end

function ObjectOriented.new(class_name)
  if class_name and type(class_name) == 'string' then
    local class = {
      __classid = ObjectOriented.__next_id(),
      __classtype = true,
      __isinstance = false,
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
  if ObjectOriented.is_type(base) then
    local type = ObjectOriented.new(class_name)
    ObjectOriented.add_superclass(type, base)
    return type
  else
    error('Error in ObjectOriented.subclass(base, class_name) : base must be a type object')
    return nil
  end
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
  return ObjectOriented.add_superclass(subclass, base)
end

function ObjectOriented.identity(class)
  return class.__classid
end

function ObjectOriented.name(class)
  return class.class_name
end

function ObjectOriented.instance(class)
  local instance = Functional.deep_clone(class)
  instance.attributes = Functional.deep_clone(class.attributes)
  instance.subclasses = Functional.deep_clone(class.subclasses)
  instance.superclasses = Functional.deep_clone(class.superclasses)
  instance.__isinstance = true
  setmetatable(instance, ObjectOriented.instance_meta)
  return instance
end

function ObjectOriented.get_attribute(object, key)
  if ObjectOriented.assert_object(object) then
    local attributes = rawget(object, 'attributes')
    local instance_attribute = rawget(attributes, key)
    if not instance_attribute then
      local superclasses = rawget(object, 'superclasses')
      for k,v in pairs(superclasses) do
        instance_attribute = ObjectOriented.get_attribute(ObjectRegistry[v], key)
        if instance_attribute then
          return instance_attribute
        end
      end
    end
    return instance_attribute
  end
end

function ObjectOriented.set_attribute(object, key, value)
  object.attributes[key] = value
  return object.attributes[key]
end

return ObjectOriented
