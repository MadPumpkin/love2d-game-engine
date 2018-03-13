require ('engine.core.Vector')
require ('engine.core.AABB')
require ('engine.core.utilities')
require ('engine.systems.scene.GraphGrammar')
require ('engine.systems.scene.TileTool')
require ('engine.systems.scene.TileSheet')


WorldGenerator = {}
WorldGenerator.__index = WorldGenerator

function WorldGenerator:create(engine)
  local generator = {
    scene = engine.Scene,
    map_set = {},
    tunnel_points = {},
    graphs = {
      background = GraphGrammar:create(),
      terrain = GraphGrammar:create(),
      terrainModifier = GraphGrammar:create(),
      terrainDecorator = GraphGrammar:create(),
      foreground = GraphGrammar:create(),
    },
    tools = {
      map = TileTool:create(0, 0, 32*16, 32*16),
      tile = TileTool:create(0, 0, 16, 16)
    }
  }
  setmetatable(generator, self)
  self.__index = self

  generator.graphs.terrain:addSymbol('S') -- Axiom := M
  generator.graphs.terrain:addSymbol('M') -- Move and might fork := uMMF | rMMF | dMMF | lMMF
  generator.graphs.terrain:addSymbol('X') -- Might be diggable := x | M | MM | MMX | X
  generator.graphs.terrain:addSymbol('F') -- Might have fork, secret or diggable := f | s | M | X
  generator.graphs.terrain:addSymbol('f') -- Constant := Fork -> Place new generator with `S`
  generator.graphs.terrain:addSymbol('s') -- Constant := Secret -> Place secret
  generator.graphs.terrain:addSymbol('x') -- Constant := Is diggable
  generator.graphs.terrain:addSymbol('u') -- Constant := Move up
  generator.graphs.terrain:addSymbol('r') -- Constant := Move right
  generator.graphs.terrain:addSymbol('d') -- Constant := Move down
  generator.graphs.terrain:addSymbol('l') -- Constant := Move left

  generator.graphs.terrain:addProduction('S', 'M')
  generator.graphs.terrain:addProduction('X', 'x')
  generator.graphs.terrain:addProduction('X', 'M')
  generator.graphs.terrain:addProduction('X', 'MM')
  generator.graphs.terrain:addProduction('X', 'MMX')
  generator.graphs.terrain:addProduction('F', 'f')
  generator.graphs.terrain:addProduction('F', 'M')
  generator.graphs.terrain:addProduction('F', 's')
  generator.graphs.terrain:addProduction('F', 'X')

  generator.graphs.terrain:addProduction('M', 'MM')
  generator.graphs.terrain:addProduction('M', 'MMF')
  generator.graphs.terrain:addProduction('M', 'uM')
  generator.graphs.terrain:addProduction('M', 'rM')
  generator.graphs.terrain:addProduction('M', 'dM')
  generator.graphs.terrain:addProduction('M', 'lM')
  generator.graphs.terrain:addProduction('M', 'drM')
  generator.graphs.terrain:addProduction('M', 'dlM')

  production = ''

  generator.graphs.terrain:setStopCondition(
    function(production, input_string)
      if #input_string > 60 then
        return true
      end
      return false
    end
  )

  return generator
end

function WorldGenerator:addMap()
  self.map_set[#self.map_set+1] = self.scene:addMap(self.tools.map.brush:getPosition(), {width=32, height=32})
  self.map_set[#self.map_set]:fill(1)
end

function WorldGenerator:createNullMap()
  local null_map = TileMap:create(self.tools.map.brush:getPosition(), {width=32, height=32})
  null_map:fill(1)
  return null_map
end

function WorldGenerator:moveMapBrush(direction)
  local initial = direction:sub(1,1)
  if initial == 'u' then
    self.tools.map:move('up')
  elseif initial == 'r' then
    self.tools.map:move('right')
  elseif initial == 'd' then
    self.tools.map:move('down')
  elseif initial == 'l' then
    self.tools.map:move('left')
  end
end

function WorldGenerator:mapAtBrush()
  local map = nil
  for i=1, #self.map_set do
    if self.tools.map.brush:intersects(self.map_set[i]:getViewRectangle()) then
      map = self.map_set[i]
      break
    end
  end
  return map
end

function WorldGenerator:mapNeighborhoodAtBrush()
  local maps = {}

  self:moveMapBrush('u')
  maps[#maps+1] = self:mapAtBrush() or self:createNullMap()
  self:moveMapBrush('d')
  self:moveMapBrush('l')
  maps[#maps+1] = self:mapAtBrush() or self:createNullMap()
  self:moveMapBrush('r')
  maps[#maps+1] = self:mapAtBrush() or self:createNullMap()
  self:moveMapBrush('r')
  maps[#maps+1] = self:mapAtBrush() or self:createNullMap()
  self:moveMapBrush('d')
  self:moveMapBrush('l')
  maps[#maps+1] = self:mapAtBrush() or self:createNullMap()
  self:moveMapBrush('u')

  return maps
end

function WorldGenerator:mapNeighborhoodAsMap(map_neighborhood)
  local map = TileMap:create({x = 0, y = 0}, {
    width = map_neighborhood[1].size.width*3,
    height = map_neighborhood[1].size.height*3
  })
  map:setTileRange(32, 0, 0, map_neighborhood[1])
  map:setTileRange(0, 32, 0, map_neighborhood[2])
  map:setTileRange(32, 32, 0, map_neighborhood[3])
  map:setTileRange(64, 32, 0, map_neighborhood[4])
  map:setTileRange(32, 64, 0, map_neighborhood[5])

  return map
end

function WorldGenerator:mapAutoTileSeams()
  local neighborhood = self:mapNeighborhoodAtBrush()
  local seam_map = self:mapNeighborhoodAsMap(neighborhood)
  seam_map:autoTileAll(0)

  local map = seam_map:getTileRangeMap({
    x=33,
    y=33,
    z=1
  }, {
    width=32,
    height=32,
    layers=1
  })
  return map
end

function WorldGenerator:autoTileAll()
  for i=1,#self.map_set do
    self.tools.map.brush:setPosition(self.map_set[i].offset.x, self.map_set[i].offset.y)
    self.map_set[i]:setTileRange(0, 0, 0, self:mapAutoTileSeams())
  end
end

function WorldGenerator:generate()
  for i=1,#self.scene.maps do
    self.scene.maps[i] = nil
  end
  for i=1,#self.map_set do
    self.map_set[i] = nil
  end
  self.scene.maps = {}
  self.map_set = {}

  self.tools.map.brush:setPosition(0, 0)

  axiom = 'S'
  terminal_string = 'fsurdlx'
  directional_string = 'urdl'
  production = self.graphs.terrain:execute(axiom)
  production = self.graphs.terrain:getWithSymbolProductions('M', production)
  production = self.graphs.terrain:getWithSymbolProductions('M', production)
  production = self.graphs.terrain:stripNonTerminalSymbols(production)

  local c = 'd'
  local previous_c = ''
  for i=1, #production do
    if directional_string:match(c) then
      previous_c = c
    end
    c = production:sub(i, i)
    if terminal_string:match(c) then
      if directional_string:match(c) then
        local map = self:mapAtBrush()
        if not map then
          self:addMap()
          map = self.map_set[#self.map_set]
        end

        self:moveMapBrush(c)
        local line_position_a, line_position_b = {x=0, y=0}, {x=0, y=0}

        if previous_c == 'u' then
          line_position_a = {
            x=map:getWidth()/2,
            y=map:getHeight()
          }
        elseif previous_c == 'r' then
          line_position_a = {
            x=0,
            y=map:getHeight()/2
          }
        elseif previous_c == 'd' then
          line_position_a = {
            x=map:getWidth()/2,
            y=0
          }
        elseif previous_c == 'l' then
          line_position_a = {
            x=map:getWidth(),
            y=map:getHeight()/2
          }
        end

        if c == 'u' then
          line_position_b = {
            x=map:getWidth()/2,
            y=0
          }
        elseif c == 'r' then
          line_position_b = {
            x=map:getWidth(),
            y=map:getHeight()/2
          }
        elseif c == 'd' then
          line_position_b = {
            x=map:getWidth()/2,
            y=map:getHeight()
          }
        elseif c == 'l' then
          line_position_b = {
            x=0,
            y=map:getHeight()/2
          }
        end

        -- self:tunnel(map, line_position_a, line_position_b)
        self.tunnel_points[#self.tunnel_points+1] = {map=map, a=line_position_a, b=line_position_b}
      end

      if c == 'f' then
        -- 'f' --> Place new fork by moving the generator and continuing with 'S'
      elseif c == 's' then
        -- 's' --> Place secret by moving the generator and creating a hidden room
      elseif c == 'x' then
        -- 'x' --> Is diggable
      end

    end
  end

  self:autoTileAll()
end

function WorldGenerator:tunnel(map, line_position_a, line_position_b)
  map:drawLine(line_position_a, line_position_b, 1, 0)
  map:drawLine(
    {x=line_position_a.x, y=line_position_a.y+1},
    {x=line_position_b.x, y=line_position_b.y+1}, 1, 0)
  map:drawLine(
    {x=line_position_a.x, y=line_position_a.y-1},
    {x=line_position_b.x, y=line_position_b.y-1}, 1, 0)
  map:drawLine(
    {x=line_position_a.x+1, y=line_position_a.y},
    {x=line_position_b.x+1, y=line_position_b.y}, 1, 0)
  map:drawLine(
    {x=line_position_a.x-1, y=line_position_a.y},
    {x=line_position_b.x-1, y=line_position_b.y}, 1, 0)
end
