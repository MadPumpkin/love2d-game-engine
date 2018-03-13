require ('engine.systems.Entity')
require ('engine.core.clock')
require ('engine.core.AABB')

require ('Components')

Player = Entity:create(component_registry)
Player.__index = Player

function Player:create(x,y)
  local player = Entity:create(component_registry)
  setmetatable(player, self)
  self.__index = self
  player:setType("player")

  player.stats = {
    health = 3,
    health_max = 3,
    projectiles = 3,
    projectile_max = 3,
    speed = 0.6,
    jump_height = 16
  }

  return Player
end

function Player:update(dt)
  self:dispatch("update", dt)
end

function Player:draw()
  self:dispatch("draw")
end
