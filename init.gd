extends Node

func _ready():
	global.mouse_update()
	if not global.stage_external.is_empty():
		global.load_stage( global.stage_external )
	else:
		global.title_open()
