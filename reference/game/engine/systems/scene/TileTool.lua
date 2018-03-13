require ('engine.core.Vector')
require ('engine.core.AABB')
require ('engine.core.utilities')


TileTool = {}
TileTool.__index = TileTool

function TileTool:create(x, y, width, height)
  local tool = {
    mode = 0,
    brush = AABB:create(x, y, width, height),
    directions = {
      up = {
        x = 0,
        y = -1
      },
      right = {
        x = 1,
        y = 0
      },
      down = {
        x = 0,
        y = 1
      },
      left = {
        x = -1,
        y = 0
      }
    }
  }
  setmetatable(tool, self)
  self.__index = self

  return tool
end

function TileTool:move(direction)
  self.brush.position.x = self.brush.position.x + self.directions[direction].x * self.brush:getWidth()
  self.brush.position.y = self.brush.position.y + self.directions[direction].y * self.brush:getHeight()
end
