require ('entity')
require ('components.animation')
require ('components.sprite')
require ('components.physics')

component_registry = ComponentRegistry:create()

component_registry:register("sprite", Sprite)
component_registry:register("animation", Animation)
component_registry:register("physics", Physics)
