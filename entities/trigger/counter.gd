extends Node3D

var count : int = 0
var total : int = 0
var message : String = ""

var targetname : String
var activate_targetname : String

func _func_godot_apply_properties( properties : Dictionary ):
	global.funcgodot_common_defs( self, properties )
	
	total = properties.total
	message = properties.message

func do_target_activate( activator : Node3D ):
	count += 1
	if count >= total:
		global.targetname_activate( activate_targetname, self )
		if not message.is_empty():
			global.message_player( message )
		else:
			global.message_player( "Sequence complete!" )
		queue_free()
	else:
		global.message_player( str( "only ", total - count, " left to go..." ) )
		
