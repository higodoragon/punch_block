extends Node

func _ready():
	if global.stage_external.is_empty():
		global.load_stage( "res://func_godot/maps/teststage01.map" )
	else:
		global.load_stage( global.stage_external )
