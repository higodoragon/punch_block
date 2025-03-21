extends Resource
class_name GibSpriteAssoc

@export var texture: Texture2D
@export var head_rect: Rect2
## where the sprite should be centered in the physics object
## and inverse this for where to spawn the head on the enemy after they die
@export var y_adjustment: float = 0.0
