local ObjectOriented = require('engine.core.ObjectOriented')

Clock = ObjectOriented.new('Clock')
Clock.paused = true
Clock.finished = false
Clock.elapsed = 0
Clock.interval = 0
Clock.overtime = 0

Clock.start = function()
  self.elapsed = 0
  self.paused = false
  self.finished = false
end

Clock.stop = function()
  self.elapsed = 0
  self.paused = true
  self.finished = false
end

Clock.pause = function()
  self.paused = true
end

Clock.unpause = function()
  self.paused = false
end

Clock.tick = function(dt)
  if not self.paused then
    if self.elapsed < self.interval then
      self.elapsed = self.elapsed + dt
    else
      self.overtime = self.elapsed - self.interval
      self.finished = true
      self.paused = true
      self.elapsed = self.overtime
    end
  end
end

return Clock
