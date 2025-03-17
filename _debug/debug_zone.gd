extends Node

@export_file('*.map') var map_path = ''
@export var stage: Node3D

func _ready():
	global.stage = stage

	# if global.stage_external.is_empty():
	# 	global.load_stage(map_path)
	# else:
	# 	global.load_stage(global.stage_external)
