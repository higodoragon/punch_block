extends Area3D

var targetname : String
var activate_targetname : String
var message : String = ""

func _on_Area_body_entered( body : Node ) -> void:
	if body == global.player:
		global.targetname_activate( activate_targetname, body )
		if not message.is_empty():
			global.message_player( message, 240 )
		queue_free()

func _func_godot_apply_properties( properties : Dictionary ):
	global.funcgodot_common_defs( self, properties )
	body_entered.connect( _on_Area_body_entered )
	
	# if activate_targetname.is_empty():
	# 	queue_free()
	# 	return
