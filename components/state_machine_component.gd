extends Node
class_name StateMachineComponent

@onready var parent : Node = get_parent()
@export var sprite : Sprite3D = null
var current_array : Array = []
var current_index : int = 0
var sticky_call : String = ""
var delay : int = 0

func set_state( array : Array, index : int = 0 ):
	sticky_call = ""
	delay = 0
	current_array = array
	current_index = index

func _physics_process(delta: float) -> void:
	if sticky_call != "":
		parent.call( sticky_call )
		
	if delay == -1:
		return
		
	if delay > 0:
		delay -= 1
		return

	while true:
		if current_array.is_empty():
			return

		if current_index >= current_array.size():
			return

		var current : Dictionary = current_array[ current_index ]
		current_index += 1
		
		if not current:
			current_index = 0
			break
		
		if "destroy" in current:
			parent.queue_free()
			break
		
		if "delay" in current:
			delay = current.delay
		else:
			delay = -2

		if "frame" in current and ( sprite != null ) and ( current.frame is int ):
			sprite.frame = current.frame

		if "texture" in current and ( sprite != null ) and ( current.texture is Texture2D ):
			sprite.texture = current.texture

		if "call" in current and current.call in parent:
			parent.call( current.call )
			
		if "sticky_call" in current and current.sticky_call in parent:
			sticky_call = current.sticky_call

		if "goto" in current:
			set_state( current.goto )

		if "loop" in current and current.loop:
			current_index = 0
		
		if "index" in current:
			current_index = current.index
		
		if delay == -2:
			# continues if states doesn't have a delay
			continue
		else:
			break
