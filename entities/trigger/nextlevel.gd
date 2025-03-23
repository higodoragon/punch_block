extends Node3D

var targetname : String
var activate_targetname : String

func _func_godot_apply_properties( properties : Dictionary ):
	global.funcgodot_common_defs( self, properties )
	
func do_target_activate( activator : Node3D ):
	global.boot_to_intermission()
