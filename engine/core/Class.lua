local set = require('engine.core.set')

local Class = {}
Class.__index = Class

Class.__next_public_id = 0
function Class:__nextId()
  self.__next_public_id = self.__next_public_id + 1
  return self.__next_public_id
end

---------- ---------- ----------
--[[ MODULE PRIVATE METHODS ]]
---------- ---------- ----------
function Class:__new(class_name, attributes, tests, hooks, meta_attributes)
  local public_attributes = {
    new = Class.__new,
    instance = Class.__instance,
    subclass = Class.__subclass,
    setAttribute = Class.__setAttribute,
  }

  local class = {
    is_class = true,
    class_id = Class:__nextId(),
    class_name = class_name or 'Class',
    super_classes = set:new(),
    sub_classes = set:new(),
    tests = tests or set:new(),
    hooks = hooks or set:new(),
    attributes = set:new(attributes),
    meta_attributes = set:new(meta_attributes)
  }
  setmetatable(class, Class)
  class.attributes:join(set:new(public_attributes))
  print(tableToString(class.attributes))
  class.attributes:clean()
  class:__hook('class.new')
  return class
end

function Class:__identity()
  return self.class_id
end

-- Clone attributes (and meta attributes) and map all other properties to parent
function Class:__instance(...)
  local instance = self:__new(unpack(...))
  instance.class_id = self.class_id
  instance.class_name = self.class_name
  instance.super_classes = self.super_classes
  instance.sub_classes = self.sub_classes
  instance.attributes = self.attributes:clone()
  instance.meta_attributes = self.meta_attributes:clone()
  instance.tests = self.tests
  instance.hooks = self.hooks
  self:__hook('class.instance')
  return instance
end

function Class:__clone(...)
  local clone = self:__new(unpack(...))
  clone.class_id = self.class_id
  clone.class_name = self.class_name:clone()
  clone.super_classes = self.super_classes:clone()
  clone.sub_classes = self.sub_classes:clone()
  clone.attributes = self.attributes:clone()
  clone.meta_attributes = self.meta_attributes:clone()
  clone.tests = self.tests:clone()
  clone.hooks = self.hooks:clone()
  self:__hook('class.clone')
  return clone
end

function Class:__superclass(super)
  if super.is_class then
    self.super_classes[#self.super_classes+1] = super
  end
end

function Class:__subclass(class_name, attributes, tests, hooks, meta_attributes, ...)
  local subclass = self:__new(
    class_name or self.class_name..'.__subclass',
    attributes or self.attributes:clone(),
    meta_attributes or self.meta_attributes:clone(),
    tests or {},
    hooks or {}
  )
  self.sub_classes[#self.sub_classes+1] = subclass
  subclass.super_classes[#subclass.super_classes+1] = self
  self:__hook('class.subclass')
  return subclass
end

function Class:__isClass(c)
  if type(c) == 'table' then
    return c['is_class'] ~= nil
  end
end

function Class:__instanceOf(c)
  if Class.__isClass(c) then
    return
  end
  return false
end

function Class:__subclassOf(super)
  if Class.__isClass(super) then
    return
  end
end

function Class:__superclassOf(sub)
  if Class.__isClass(sub) then
    return
  end
end

function Class:__setAttribute(attribute, value, slots, ...)
  local type_string = ''
  if Class:__isClass(value) then
    type_string = '(Class:'..value.class_id..').'..value.class_name
  else
    type_string = type(value)
  end
  self.attributes:add(attribute, {
    type_string = type_string,
    value = value,
    slots = slots,
    meta = ...
  })
  self:__hook(attribute, 'attribute.set')
end

function Class:__getAttribute(attribute)
  local selected_attribute = nil
  if self.attributes:contains(attribute) then
    selected_attribute = self.attributes[attribute]
  elseif #self.super_classes > 0 then
    for k,v in pairs(self.super_classes:flatten()) do
      local attribute_check = k[v]:__getAttribute(attribute)
      if attribute_check ~= nil then
        selected_attribute = attribute_check
      end
    end
  end
  self:__hook(attribute, 'attribute.get')
  return selected_attribute
end

function Class:__getAttributeValue(attribute)
  local selected_attribute = self:__getAttribute(attribute)
  if selected_attribute then
    return selected_attribute.value
  end
  return selected_attribute
end

Class.message_hooks = set:new({
  'class.new',
  'class.instance',
  'class.clone',
  'class.subclass',
  'attribute.get',
  'attribute.set',
  'slot.sending',
  'slot.receiving',
  'slot.connecting'
})

function Class:__hook(hook)
  if self:__hasHook(hook) then
    return self.hooks[hook]()
  end
end

function Class:__getHook(hook)
  return function ()
    self:__hook(hook)
  end
end

function Class:__setHook(hook, method)
  if self.message_hooks:contains(hook) then
    self.hooks[hook] = method
  end
end

function Class:__hasHook(hook)
  if self.message_hooks:contains(hook) then
    return self.hooks[hook] ~= nil
  end
end

function Class:__index(attribute)
  if self.attributes:contains(attribute) then
    return self:__getAttributeValue(attribute)
  else
    return Class[attribute]
  end
end

function Class:__call(...)
  return self:instance(unpack(...))
end


function Class:__tostring()
  local result = self.class_name..'\n'
  result = result..tableToString(self)..'\n'

  return result
end


---------- ---------- ----------
--[[ MODULE PUBLIC METHODS ]]
---------- ---------- ----------

return Class:__new('__Class')
