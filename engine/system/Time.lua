local ObjectOriented = require ('engine.core.ObjectOriented')
local Functional = require ('engine.core.Functional')
local Clock = require ('engine.system.types.Clock')

Time = ObjectOriented.new('Time')
Time.clocks = Set()

-- TODO NEXT!!!!!
function Time:update(dt)
  self.clocks:clean()
  self.clocks:dispatch('tick', dt)
end

function Time:draw()
  -- TODO add if debug, show clocks
end

function Time:clockInstance()
  return self.clocks:add_element(Clock())
end

function Time:removeClock(handle)
  self.clocks:remove_element(handle)
end

function Time:getClockElapsed(handle)
  return self.clocks[handle].elapsed
end

function Time:getClockInterval(handle)
  return self.clocks[handle].interval
end

function Time:getClockPaused(handle)
  return self.clocks[handle].paused
end

function Time:getClockFinished(handle)
  return self.clocks[handle].finished
end

function Time:startClock(handle)
  self.clocks[handle]:start()
end

function Time:stopClock(handle)
  self.clocks[handle]:stop()
end

function Time:pauseClock(handle)
  self.clocks[handle]:pause()
end

function Time:unpauseClock(handle)
  self.clocks[handle]:unpause()
end

return Time
