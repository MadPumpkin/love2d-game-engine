local ObjectOriented = require('engine.core.ObjectOriented')
local Functional = require('engine.core.Functional')

--[[
  Set
    impure functional style over sets of objects
]]
Set = ObjectOriented.new('Set')
Set.elements = {}
Set.typename_filter = nil

Set.set_type_filter = function(self, type_name)
  if ObjectOriented.type_exists(type_name) then
    self.typename_filter = type_name
  else
    error('Set.set_type_filter(set, type_name) : type_name must be an existing type (from ObjectOriented.type_list() )')
    return nil
  end
end


Set.add_element = function(self, element, ignore_filter)
  local no_filter_exists = (not self.typename_filter)
  local element_matches_filter = (ObjectOriented.is_object(element) and (ObjectOriented.name(element) == self.typename_filter))
  if no_filter_exists or ignore_filter or element_matches_filter then
    self.elements[#self.elements+1] = element
    return #self.elements
  else
    error('Set.add_element(set, element, ignore_filter) : element must be object type matching set.typename_filter, or ignore_filter must be true')
    return nil
  end
  error('Set.add_element this should not be reached')
end

Set.remove_element = function(self, handle)
  self.elements[handle] = nil
end

Set.clean = function(self)
  self.elements = Functional.clean(self.elements)
end

Set.for_each = function(self, method, ...)
  for key, element in pairs(self.elements) do
    self.elements[key] = method(element, ...)
  end
end

Set.dispatch = function(self, method, ...)
  for key, element in pairs(self.elements) do
    self.elements[key]:method(...)
  end
end

Set.operate = function(self, method_name, ...)
  if Functional[method_name] then
    self.elements = Functional[method_name](self.elements, ...)
  else
    error('Set.operate(set, method_name, ...) : method_name must be the name of a valid function within the Functional module')
    return nil
  end
end

return Set
