require ('core.clock')
require ('core.set')

require ('entity')
require ('components')
require ('bullet')


Player = Entity:create(component_registry)
Player.__index = Player

function Player:create()
  local player = Entity:create(component_registry)
  setmetatable(player, self)
  self.__index = self
  player:setType("player")


  player.state = "air"
  player.bullets = {}
  player.cooldown = Clock:create(0.5)
  player.stats = {
    health = 10,
    health_max = 10,

    power = 10,
    power_max = 10,

    attack = 10,
    speed = 0.8,
    jump_height = 8
  }

  player:addComponent("sprite")
  player:addComponent("animation")
  player:addComponent("physics")

  player:getComponent("physics"):setSize(30, 30)

  player:execute("sprite", "load", "data/hare.png")
  player:execute("animation", "load", player:getComponent("sprite"), 0.05)

  player:execute("animation", "addFrame", 0, 0, 32, 32)
  player:execute("animation", "addFrame", 32, 0, 32, 32)
  player:execute("animation", "addFrame", 64, 0, 32, 32)
  player:execute("animation", "addFrame", 96, 0, 32, 32)
  player:execute("animation", "addFrame", 128, 0, 32, 32)
  player:execute("animation", "addFrame", 160, 0, 32, 32)
  player:execute("animation", "addFrame", 192, 0, 32, 32)
  player:execute("animation", "addFrame", 224, 0, 32, 32)
  player:execute("animation", "addFrame", 256, 0, 32, 32)
  player:execute("animation", "addFrame", 288, 0, 32, 32)
  player:execute("animation", "addFrame", 320, 0, 32, 32)
  player:execute("animation", "addFrame", 352, 0, 32, 32)

  player:getComponent("animation").timer:start()
  player.cooldown:start()

  return player
end

function Player:update(dt)
  -- Components
  local animation = self:getComponent("animation")
  local physics = self:getComponent("physics")

  -- Movement
  if love.keyboard.isDown("a") then
    animation.timer:unpause()
    animation.flip_horizontal = true
    physics.velocity:setX(physics.velocity:getX() - self.stats.speed)

  elseif love.keyboard.isDown("d") then
    animation.timer:unpause()
    animation.flip_horizontal = false
    physics.velocity:setX(physics.velocity:getX() + self.stats.speed)

  else
    animation.timer:pause()
  end

  -- Jumping
  if love.keyboard.isDown("space") then
    if self.state == "ground" then
      physics.velocity:setY(physics.velocity:getY() - self.stats.jump_height )
    end
  end

  -- Attacking
  self.cooldown:update(dt)
  if love.keyboard.isDown("left") then
    if self.cooldown.finished then
      self.bullets[#self.bullets+1] = Bullet:create(physics:getPosition():getX(), physics:getPosition():getY()+8)
      local bullet_physics = self.bullets[#self.bullets]:getComponent("physics")

      if not animation.flip_horizontal then -- Right facing
        bullet_physics:setPosition( physics:getPosition():getX() + physics:getSize():getWidth(), bullet_physics:getPosition():getY())
        bullet_physics:setVelocity(self.stats.attack, 0)
      else
        bullet_physics:setPosition( physics:getPosition():getX(), bullet_physics:getPosition():getY() )
        bullet_physics:setVelocity(-self.stats.attack, 0)
      end

      self.cooldown:start()
    end
  end

  -- Update active bullets, remove inactive ones
  for i=1,#self.bullets do
    if self.bullets[i].active then
      self.bullets[i]:update(dt)
    else
      self.bullets[i] = nil
    end
  end
  self.bullets = cleanNils(self.bullets)

  -- Update animation
  self:execute("animation", "update", dt)
end

function Player:draw()
  local position = self:getComponent("physics"):getPosition()

  for i=1,#self.bullets do
    self.bullets[i]:draw()
  end

  self:execute("animation", "draw", position:getX(), position:getY())
end

function Player:drawGUI()
  love.graphics.push()
  love.graphics.setColor(200, 200, 200)
  love.graphics.rectangle( "fill", 20, 20, self.stats.health_max*10+4, 14)
  love.graphics.setColor(200, 20, 20)
  love.graphics.rectangle( "fill", 22, 22, self.stats.health*10, 10)

  love.graphics.setColor(200, 200, 200)
  love.graphics.rectangle( "fill", 20, 50, self.stats.power_max*10+4, 14)
  love.graphics.setColor(80, 40, 200)
  love.graphics.rectangle( "fill", 22, 52, self.stats.power*10, 10)
  love.graphics.pop()
end
