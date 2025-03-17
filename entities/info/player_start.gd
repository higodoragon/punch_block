extends Node3D

func _ready():
	global.player_position = global_position
	global.player_rotation = global_rotation
	self.queue_free()
