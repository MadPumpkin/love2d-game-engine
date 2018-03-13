require ('core.AABB')


World = {}
World.__index = self

function World:create(camera, player)
  local world = {
    entities = {},
    width = 40,
    height = 200,
    tilesheet = {
      path = "data/tilesheet.png",
      image = nil,
      quads = {},
      tile = {
        size = 16
      }
    },
    generator = {
      pencil = {
        position = { x=0, y=0 },
        down = false,
        value = 1
      }
    },
    map = {}
  }
  setmetatable(world,self)
  self.__index = self

  world.camera = camera
  world.entities[1] = player
  world:initialize()
  world:generate()

  return world
end

function World:setTile(x, y, t)
  if 0 < x and x <= self.width and 0 < y and y <= self.height then
    if -1 < t and t <= #self.tilesheet.quads then
      self.map[y][x] = t
    end
  end
end

function World:getTile(x, y)
  if 0 < x and x <= self.width and 0 < y and y <= self.height then
    return self.map[y][x]
  else
    return -1
  end
end

function World:gridAlign(value)
  return math.floor(value/self.tilesheet.tile.size)*self.tilesheet.tile.size
end

function World:getTileAtPoint(x, y)
  local aligned_x = math.floor(x/self.tilesheet.tile.size)
  local aligned_y = math.floor(y/self.tilesheet.tile.size)
  return self:getTile(aligned_x, aligned_y)
end

function World:setTileAtPoint(x, y, t)
  local aligned_x = math.floor(x/self.tilesheet.tile.size)
  local aligned_y = math.floor(y/self.tilesheet.tile.size)
  self:setTile(aligned_x, aligned_y, t)
end

function World:getTileIndexAtPoint(x, y)
  return math.floor(x/self.tilesheet.tile.size), math.floor(y/self.tilesheet.tile.size)
end

function World:getTileBoundingBox(x, y)
  local tx, ty = self:gridAlign(x), self:gridAlign(y)
  return AABB:create(tx, ty, self.tilesheet.tile.size, self.tilesheet.tile.size)
end





function World:autoTile(x, y)
  --[[local t = self:getTile(x,y)
  local t_up = self:getTile(x,y-1)

  if 0 < t and t <= 3 then
    if t_up == 0 then
      self:setTile(x,y,t+3)

      local mushroom_rate = 1 --love.math.random(3)
      if mushroom_rate == 1 then
        self:setTile(x,y-1,t+6)
      end

    end
  end
  ]]
end





function World:draw()
  love.graphics.setColor(255, 255, 255)

  for y=1, self.height do
    for x=1, self.width do
      if self.map[y][x] > 0 then
        love.graphics.push()
        love.graphics.draw(self.tilesheet.image, self.tilesheet.quads[self.map[y][x]],x*16,y*16)
        love.graphics.pop()
      end
    end
  end
end

--[[ Initialization ]]
function World:initialize()

  love.graphics.setBackgroundColor(40,20,50)
  love.graphics.setColor(255, 255, 255)
  love.graphics.setNewFont(12)

  self.tilesheet.image = love.graphics.newImage(self.tilesheet.path)
  self.tilesheet.image:setFilter("nearest", "nearest")

  self.tilesheet.quads[#self.tilesheet.quads+1] = love.graphics.newQuad(0,0,16,16, self.tilesheet.image:getWidth(), self.tilesheet.image:getHeight())
  self.tilesheet.quads[#self.tilesheet.quads+1] = love.graphics.newQuad(16,0,16,16, self.tilesheet.image:getWidth(), self.tilesheet.image:getHeight())
  self.tilesheet.quads[#self.tilesheet.quads+1] = love.graphics.newQuad(32,0,16,16, self.tilesheet.image:getWidth(), self.tilesheet.image:getHeight())
  self.tilesheet.quads[#self.tilesheet.quads+1] = love.graphics.newQuad(48,0,16,16, self.tilesheet.image:getWidth(), self.tilesheet.image:getHeight())
  self.tilesheet.quads[#self.tilesheet.quads+1] = love.graphics.newQuad(64,0,16,16, self.tilesheet.image:getWidth(), self.tilesheet.image:getHeight())
  self.tilesheet.quads[#self.tilesheet.quads+1] = love.graphics.newQuad(80,0,16,16, self.tilesheet.image:getWidth(), self.tilesheet.image:getHeight())
  self.tilesheet.quads[#self.tilesheet.quads+1] = love.graphics.newQuad(96,0,16,16, self.tilesheet.image:getWidth(), self.tilesheet.image:getHeight())
  self.tilesheet.quads[#self.tilesheet.quads+1] = love.graphics.newQuad(112,0,16,16, self.tilesheet.image:getWidth(), self.tilesheet.image:getHeight())
  self.tilesheet.quads[#self.tilesheet.quads+1] = love.graphics.newQuad(128,0,16,16, self.tilesheet.image:getWidth(), self.tilesheet.image:getHeight())

end

function World:generate()

  for y=1, self.height, 1 do
    self.map[y] = {}
    for x=1, self.width, 1 do

        self.map[y][x] = love.math.random(1,3)

    end
  end

  self.generator.pencil.down = false
  self.generator.pencil.position.x = 0
  self.generator.pencil.position.y = 0
  self.generator.pencil.value = 0

  for row=1, self.height, 1 do
    local pencil_start = love.math.random( 2, 8 )
    local pencil_stop = love.math.random( self.width-8, self.width-2 )

    self.generator.pencil.position.x = pencil_start
    self.generator.pencil.position.y = row

    for tile=1, pencil_stop-pencil_start, 1 do
      self:setTile( pencil_start+tile, row, self.generator.pencil.value )
    end
  end

  for y=1, self.height, 1 do
    for x=1, self.width, 1 do
      self:autoTile(x,y)
    end
  end
end

function World:update(dt)
  for y=1, self.height do
    for x=1, self.width do
      -- Do nothing
    end
  end

  for ent=1, #self.entities do
    -- Get the entities physics component, if it doesn't have this it can't move
    local entity = self.entities[ent]
    local physics = entity:getComponent("physics")


    -- Apply gravity
    if entity.state == "air" then
      physics.velocity:setY(physics.velocity:getY() + 0.8)
    end


    local tile_collisions = {}
    -- Top left
    tile_collisions[#tile_collisions+1] = self:getTileAtPoint( physics.position:getX() + physics.velocity:getX(), physics.position:getY() + physics.velocity:getY() )
    -- Top right
    tile_collisions[#tile_collisions+1] = self:getTileAtPoint( physics.position:getX() + physics.size:getWidth() + physics.velocity:getX(), physics.position:getY() + physics.velocity:getY() )
    -- Bottom left
    tile_collisions[#tile_collisions+1] = self:getTileAtPoint( physics.position:getX() + physics.velocity:getX(), physics.position:getY() + physics.size:getHeight() + physics.velocity:getY() )
    -- Bottom right
    tile_collisions[#tile_collisions+1] = self:getTileAtPoint( physics.position:getX() + physics.size:getWidth() + physics.velocity:getX(), physics.position:getY() + physics.size:getHeight() + physics.velocity:getY() )


    local collision = false
    for t=1, #tile_collisions do
      if 0 < tile_collisions[t] then
        collision = true
      end
    end

    if ((0 < tile_collisions[3]) and (0 < tile_collisions[4])) then
      entity.state = "ground"
    else
      entity.state = "air"
    end

    -- If would be solid tiles in the entities next position

    if collision then
      local continuations = math.floor( (physics.position:getX() + physics.velocity:getX()) / 10 )
      local current_position = physics.position
      local previous_position = physics.position

      --local tiles = {}
      for iteration=1, continuations do
        local tiles = {} --[continuation] = {}
        -- Top left
        tiles[#tiles+1] = self:getTileBoundingBox( physics.position:getX() + physics.velocity:getX(), physics.position:getY() + physics.velocity:getY() )
        -- Top right
        tiles[#tiles+1] = self:getTileBoundingBox( physics.position:getX() + physics.size:getWidth() + physics.velocity:getX(), physics.position:getY() + physics.velocity:getY() )
        -- Bottom left
        tiles[#tiles+1] = self:getTileBoundingBox( physics.position:getX() + physics.velocity:getX(), physics.position:getY() + physics.size:getHeight() + physics.velocity:getY() )
        -- Bottom right
        tiles[#tiles+1] = self:getTileBoundingBox( physics.position:getX() + physics.size:getWidth() + physics.velocity:getX(), physics.position:getY() + physics.size:getHeight() + physics.velocity:getY() )

        for t=1, #tiles do
          -- If the tile is solid
          if 0 < tile_collisions[t] then
            --physics.position = previous_position
            physics:resolveIntersection(tiles[t])
          end
        end
      end

    else
      entity.state = "air"
    end

    physics.position:setX(physics.position:getX() + physics.velocity:getX())
    physics.velocity:setX(physics.velocity:getX() * 0.9)

    physics.position:setY(physics.position:getY() + physics.velocity:getY())
    physics.velocity:setY(physics.velocity:getY() * 0.9)

  end

end

function World:keypressed(key)
  if key == '=' then
    self:generate()
    self.entities[1]:getComponent("physics"):setPosition(128,0)
  end
end
