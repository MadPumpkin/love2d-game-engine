require ('engine.systems.Time')
require ('engine.systems.Scene')
require ('engine.systems.World')

--[[ ENGINE ]]

Engine = {}
Engine.__index = engine

function Engine:create()
  local engine = {}
  setmetatable(engine, self)
  self.__index = self

  engine.states = {}
  engine.current_state = nil

  engine.Time = Time:create()
  engine.World = World:create()
  engine.Scene = Scene:create()

  return engine
end

function Engine:update(dt)
  self.Time:update(dt)
  self.World:update(dt)
  self.Scene:update(dt)
end

function Engine:draw()
  self.Time:draw()
  self.World:draw()
  self.Scene:draw()
end
