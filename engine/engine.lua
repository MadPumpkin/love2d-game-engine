local Functional = require 'engine.core.Functional'
local ObjectOriented = require 'engine.core.ObjectOriented'
local Set = require 'engine.core.Set'
-- Systems
local Time = require('engine.system.Time')
local Scene = require('engine.system.Scene')
local World = require('engine.system.World')
local Entity = require('engine.system.Entity')
local ComponentRegistry = require('engine.system.ComponentRegistry')

local Engine = ObjectOriented.new('Engine')
Engine.systems = Set()
Engine.systems:add_element(Time())
Engine.systems:add_element(Scene())
Engine.systems:add_element(World())
Engine.systems:add_element(Entity())
Engine.systems:add_element(ComponentRegistry())

Engine.call = function(self, method_name, ...)
  Engine.systems:dispatch(method_name, ...)
end

Engine.update = function(self, ...)
  Engine.call('update', ...)
end

Engine.update = function(self, ...)
  Engine.call('draw', ...)
end

return Engine
