extends StaticBody3D
class_name FuncButton

var targetname : String
var activate_targetname : String
var message : String

func _func_godot_apply_properties( properties : Dictionary ):
	global.funcgodot_common_defs( self, properties )

func do_die( _killer ):
	if global.button_sfx != null:
		global.audio_play_at( global.button_sfx, global_position )
	
	$button/Button_Active.visible = false
	$button/Button_Deactive.visible = true
	process_mode = Node.PROCESS_MODE_DISABLED
