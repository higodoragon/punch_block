extends Node3D

var targetname : String
var activate_targetname : String

func _func_godot_apply_properties( properties : Dictionary ):
	global.funcgodot_common_defs( self, properties )
	
func do_target_activate( activator : Node3D ):
	print( str( "KILLS: ", global.enemy_count_killed / global.enemy_count * 100, "%" ) )
	print( str( "TIME: ", global.stage_time / 60 ) )
	global.load_next_level()
