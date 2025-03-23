extends Node3D

@export var spin_speed_cam := 5.0
@export var spin_speed_parent := 20.0

var pause_active : bool = false
var pause_active_old : bool = false

func _input(event: InputEvent) -> void:
	if event.is_pressed() and global.pause_active:
		global.pause_active = true

func _process(delta):
	$CanvasLayer.visible = not global.pause_active
	self.rotation_degrees.y += spin_speed_cam * delta
	%TitleParent.rotation_degrees.y += spin_speed_parent * delta
