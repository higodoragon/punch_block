extends Node

@export var model: Node3D
@onready var anim: AnimationPlayer = model.find_child('AnimationPlayer')

@export var fps: float = 6.0
@onready var step_time: float = 1.0 / fps
var timer := 0.0


func _ready():
	anim.set_process_callback(AnimationPlayer.ANIMATION_PROCESS_MANUAL)
	# anim.playback_default_blend_time = 0.5


func _process(delta):
	timer += delta
	while timer >= step_time:
		anim.advance(step_time)
		timer -= step_time