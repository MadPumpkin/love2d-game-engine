require ('engine.core.Vector')
require ('engine.core.AABB')
require ('engine.systems.scene.TileSheet')
require ('engine.core.utilities')


TileMap = {}
TileMap.__index = TileMap

function TileMap:create(offset, size)
  local tile_map = {
    offset = offset,
    size = size,
    tilesheet = {},
    map = {}
  }
  setmetatable(tile_map, self)
  self.__index = self

  tile_map.map = {}
  tile_map.map[1] = {}
  for y=1, tile_map.size.height do
    tile_map.map[1][y] = {}
    for x=1, tile_map.size.width do
      tile_map.map[1][y][x] = 0
    end
  end
  tile_map.size.layers = #tile_map.map

  tile_map.tilesheet = TileSheet:create("data/tilesheet.png", {width=16, height=16})

  return tile_map
end

function TileMap:getDepth()
  return self.size.layers
end

function TileMap:getHeight()
  return self.size.height
end

function TileMap:getWidth()
  return self.size.width
end

function TileMap:getDimensions()
  return self:getWidth(), self:getHeight(), self:getDepth()
end

function TileMap:getViewRectangle()
  local width, height = self:getWidth()*self.tilesheet.tile_size.width, self:getHeight()*self.tilesheet.tile_size.height
  return AABB:create(self.offset.x, self.offset.y, width, height)
end

function TileMap:forEachTile(tile_method, ...)
  for z=1, self.size.layers do
    for y=1, self.size.height do
      for x=1, self.size.width do
        tile_method(self, x, y, z, ...)
      end
    end
  end
end

function TileMap:forTileInRange(range_position, range_size, tile_method, ...)
  for z = range_position.z, range_size.layers do
    for y = range_position.y, range_size.height do
      for x = range_position.x, range_size.width do
        tile_method(self, x, y, z, ...)
      end
    end
  end
end

function TileMap:autoTile(x, y, z, fill_outside)
  local t = self:getTile(x, y, z)
  if t > 0 then
    local up = self:getTile(x, y-1, z) > 0 and 1 or 0
    local right = self:getTile(x+1, y, z) > 0 and 1 or 0
    local down = self:getTile(x, y+1, z) > 0 and 1 or 0
    local left = self:getTile(x-1, y, z) > 0 and 1 or 0

    if up == -1 then up = fill_outside end
    if right == -1 then right = fill_outside end
    if down == -1 then down = fill_outside end
    if left == -1 then left = fill_outside end

    local tile_index = ((((left*8) + down*4) + right*2) + up) + 1

    self:setTile(x, y, z, tile_index)
  end
end

function TileMap:autoTileAll(fill_outside)
  self:forEachTile(self.autoTile, fill_outside or 1)
end

function TileMap:fill(fill_value)
  self:forEachTile(self.setTile, fill_value)
end

function TileMap:tileInMap(x, y, z)
  if 0 < x and x <= self.size.width
  and 0 < y and y <= self.size.height
  and 0 < z and z <= self.size.layers then
    return true
  else
    return false
  end
end

function TileMap:setTile(x, y, z, tile)
  if self:tileInMap(x, y, z) then
    if -1 < tile and tile <= #self.tilesheet.quads then
      self.map[z][y][x] = tile
    end
  end
end

function TileMap:getTile(x, y, z)
  if self:tileInMap(x, y, z) then
    return self.map[z][y][x]
  else
    return 1
  end
end

function TileMap:drawLine(a, b, z, tile)
  local width = b.x - a.x
  local height = b.y - a.y

  local sign_start = { x=math.sign(width), y=math.sign(height) }
  local sign_end = { x=math.sign(width), y=0 }

  local longest = math.abs(width)
  local shortest = math.abs(height)

  if shortest > longest then
    longest = math.abs(height)
    shortest = math.abs(width)
    sign_end.y = math.sign(height)
    sign_end.x = 0
  end

  local x = a.x
  local y = a.y

  local numerator = math.floor(longest/2 ^ 1)

  for i=0,longest do
    self:setTile(x, y, z, tile)
    numerator = numerator + shortest
    if numerator > longest then
      numerator = numerator - longest
      x = x + sign_start.x
      y = y + sign_start.y
    else
      x = x + sign_end.x
      y = y + sign_end.y
    end
  end
end

function TileMap:gridAlign(x, y)
  return
    math.floor(value/self.tilesheet.tile.size.width)*self.tilesheet.tile.size.width,
    math.floor(value/self.tilesheet.tile.size.height)*self.tilesheet.tile.size.height
end

function TileMap:getTileAtPoint(x, y, z)
  local aligned_x = math.floor(x/self.tilesheet.tile.size.width)
  local aligned_y = math.floor(y/self.tilesheet.tile.size.height)
  return self:getTile(aligned_x, aligned_y, z)
end

function TileMap:setTileAtPoint(x, y, z, tile)
  local aligned_x = math.floor(x/self.tilesheet.tile.size.width)
  local aligned_y = math.floor(y/self.tilesheet.tile.size.height)
  self:setTile(x, y, z, tile)
end

function TileMap:getTilePositionAtPoint(x, y)
  return
    math.floor(x/self.tilesheet.tile.size.width),
    math.floor(y/self.tilesheet.tile.size.height)
end

function TileMap:getTileBoundingBox(x, y)
  local tx, ty = self:gridAlign(x, y)
  return AABB:create(tx, ty, self.tilesheet.tile.size.width, self.tilesheet.tile.size.height)
end

function TileMap:getTileRangeMap(range_position, range_size)
  local range = self:create({x=0, y=0}, range_size)

  for z = 1, range_size.layers do
    for y = 1, range_size.height do
      for x = 1, range_size.width do
        range:setTile(x, y, z, self:getTile(range_position.x-1+x, range_position.y-1+y, range_position.z-1+z))
      end
    end
  end

  return range
end

function TileMap:setTileRange(offset_x, offset_y, offset_z, range_map)
  if range_map then
    for z = 1, range_map.size.layers do
      for y = 1, range_map.size.height do
        for x = 1, range_map.size.width do
          self:setTile(offset_x+x, offset_y+y, offset_z+z, range_map:getTile(x, y, z))
        end
      end
    end
  end
end

function TileMap:draw()
  love.graphics.push()
  love.graphics.translate(self.offset.x, self.offset.y)
  love.graphics.setColor(255, 255, 255)
  for z=1, self.size.layers do
    for y=1, self.size.height do
      for x=1, self.size.width do
        local t = self:getTile(x, y, z)
        if t > 0 then
          -- love.graphics.setColor(255, 255, 255)
          love.graphics.draw(self.tilesheet.image, self.tilesheet:getTileRenderable(t), x*self.tilesheet.tile_size.width, y*self.tilesheet.tile_size.height)
        end
      end
    end
  end
  love.graphics.pop()
end
