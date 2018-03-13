require ('core.vector')

Sprite = {}
Sprite_mt = { __index = Sprite }

function Sprite:create()
  local sprite = {
    path = "",
    image = nil,
    filter = "nearest",
    flip_horizontal = false
  }
  setmetatable(sprite, Sprite_mt)
  return sprite
end

function Sprite:load(path, filter)
  self.path = path
  self.image = love.graphics.newImage(self.path)
  self.filter = filter or "nearest"
  self.image:setFilter(self.filter, self.filter)
  self.flip_horizontal = false
end

function Sprite:draw(x, y)
  love.graphics.draw(self.image, x, y)
end
