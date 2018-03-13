require ('engine.core.Vector')
require ('engine.core.AABB')


TileSheet = {}
TileSheet.__index = TileSheet

function TileSheet:create(path, tile_size)
  local tile_sheet = {
    path = path,
    image = nil,
    quads = {},
    tile_size = tile_size
  }
  setmetatable(tile_sheet, self)
  self.__index = self

  tile_sheet:loadTiles()

  return tile_sheet
end

function TileSheet:loadTiles()
  love.graphics.setColor(255, 255, 255)

  self.image = love.graphics.newImage(self.path)
  self.image:setFilter("nearest", "nearest")

  for j=0,self.image:getHeight()/self.tile_size.height do
    for i=0,self.image:getWidth()/self.tile_size.width do
      self.quads[#self.quads+1] = love.graphics.newQuad(i*self.tile_size.width, j*self.tile_size.height, self.tile_size.width, self.tile_size.height, self.image:getWidth(), self.image:getHeight())
    end
  end
end

function TileSheet:getTileRenderable(x, y)
  if y ~= nil then
    return self.quads[x* (self.image:getWidth()/self.tile_size.width) + y]
  else
    return self.quads[x]
  end
end
