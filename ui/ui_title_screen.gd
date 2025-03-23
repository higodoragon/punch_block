extends Node3D

@export var spin_speed_cam := 5.0
@export var spin_speed_parent := 20.0

func _process(delta):
	$CanvasLayer.visible = not global.pause_active
	self.rotation_degrees.y += spin_speed_cam * delta
	%TitleParent.rotation_degrees.y += spin_speed_parent * delta
