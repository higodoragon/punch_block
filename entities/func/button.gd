extends StaticBody3D
class_name FuncButton

var targetname : String
var activate_targetname : String
var message : String

func _func_godot_apply_properties( properties : Dictionary ):
	global.funcgodot_common_defs( self, properties )
