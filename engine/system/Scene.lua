local ObjectOriented = require ('engine.core.ObjectOriented')
require ('engine.math.Vector')
require ('engine.math.AABB')
require ('engine.systems.scene.Camera')
require ('engine.systems.scene.TileMap')
require ('engine.systems.scene.TileSheet')

Scene = ObjectOriented.new('Scene')
Scene.maps = {}
Scene.sprites = {}
Scene.cameras = {}
Scene.active_camera = nil
Scene.main_camera = Scene.addCamera(Scene, nil)
Scene.setActiveCamera(Scene, Scene.main_camera)


function Scene:setActiveCamera(camera)
  self.active_camera = camera
  for camera=1, #self.cameras do
    self.cameras[camera]:deactivate()
  end
  self.active_camera:activate()
end

function Scene:addCamera(target)
  self.cameras[#self.cameras+1] = Camera:create(target)
  return self.cameras[#self.cameras]
end

function Scene:addMap(offset, size)
  self.maps[#self.maps+1] = TileMap:create(offset, size)
  return self.maps[#self.maps]
end

function Scene:addSprite(sprite)
  self.sprites[#self.sprites+1] = sprite
  return self.sprites[#self.sprites]
end

function Scene:update(dt)
  self.active_camera:update(dt)
  --TODO update sprites
end

function Scene:draw()
  self.active_camera:drawBegin()
  love.graphics.setColor(255, 255, 255)
  for map=1, #self.maps do
    self.maps[map]:draw()
  end

  love.graphics.setColor(255, 255, 255)
  for sprite=1, #self.sprites do
    self.sprites[sprite]:draw()
  end

  self.active_camera:drawEnd()
end
