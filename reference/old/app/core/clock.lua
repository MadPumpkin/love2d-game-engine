Clock = {}
Clock.__index = Clock

function Clock:create(interval)
  local clock = {
    paused = true,
    elapsed = 0,
    interval = interval or 0,
    finished = false
  }
  setmetatable( clock, self )
  return clock
end

function Clock:start()
  self.elapsed = 0
  self.paused = false
  self.finished = false
end

function Clock:stop()
  self.elapsed = 0
  self.paused = true
  self.finished = false
end

function Clock:pause()
  self.paused = true
end

function Clock:unpause()
  self.paused = false
end

function Clock:update(dt)
  if not self.paused then
    if self.elapsed < self.interval then
      self.elapsed = self.elapsed + dt
    else
      self.finished = true
      self.paused = true
      self.elapsed = 0
    end
  end
end
