require ('core.clock')

Animation = {}
Animation_mt = { __index = Animation }

function Animation:create()
  local animation = {
    sprite = nil,
    timer = nil,
    current_frame = nil,
    flip_horizontal = nil,
    quads = nil
  }
  setmetatable(animation, Animation_mt)
  return animation
end

function Animation:load(sprite, frame_time)
  self.sprite = sprite
  self.timer = Clock:create(frame_time or 0.2)
  self.current_frame = 1
  self.flip_horizontal = false
  self.quads = {}
end

function Animation:next()
  if self.current_frame < #self.quads then
    self.current_frame = self.current_frame + 1
  else
    self.current_frame = 1
  end
end

function Animation:addFrame(x, y, w, h)
  if self.sprite then
    self.quads[#self.quads+1] = love.graphics.newQuad(x, y, w, h, self.sprite.image:getWidth(), self.sprite.image:getHeight())
  else
    error("Animation.addFrame: No associated sprite")
  end
end

function Animation:update(dt)
  self.timer:update(dt)
  if self.timer.finished then
    self:next()
    self.timer:start()
  end
  if self.timer.paused then
    self.current_frame = 2
  end
end

function Animation:draw(x, y)
  if self.sprite then
    love.graphics.push()
    love.graphics.setColor(255, 255, 255)
    love.graphics.translate(x, y)
    local scale_x, offset_x = 1, 0
    if self.flip_horizontal then
      scale_x = -1
      offset_x = math.floor(self.sprite.image:getWidth()/(#self.quads-1))
    end
    love.graphics.draw(self.sprite.image, self.quads[self.current_frame], 0, 0, 0, scale_x, 1, offset_x)
    love.graphics.pop()
  else
    error("Animation.draw: No associated sprite")
  end
end
