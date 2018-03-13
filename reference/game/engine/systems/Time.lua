require ('engine.core.set')
require ('engine.core.Clock')


Time = {}
Time.__index = Time

function Time:create()
  local time = {
    timers = {}
  }
  setmetatable( time, self )
  self.__index = self
  return time
end

function Time:update(dt)
  for key, value in pairs(self.timers) do
    if self.timers[key] ~= nil then
      self.timers[key]:update(dt)
    end
  end
end

function Time:draw()
  -- Do nothing, TODO add if debug, show timers
end

--[[ Timers ]]

function Time:addTimer(timer)
  self.timers[#self.timers+1] = timer
  local handle = #self.timers
  return handle
end

function Time:removeTimer(timer)
  self.timers[timer] = nil
end

function Time:getTimerElapsed(handle)
  return self.timers[handle]:getElapsed()
end

function Time:getTimerInterval(handle)
  return self.timers[handle]:getInterval()
end

function Time:timerIsPaused(handle)
  return self.timers[handle]:isPaused()
end

function Time:timerIsFinished(handle)
  return self.timers[handle]:isFinished()
end

function Time:startTimer(handle)
  self.timers[handle]:start()
end

function Time:stopTimer(handle)
  self.timers[handle]:stop()
end

function Time:pauseTimer(handle)
  self.timers[handle]:pause()
end

function Time:unpauseTimer(handle)
  self.timers[handle]:unpause()
end
