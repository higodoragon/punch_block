class_name CharacterBase extends CharacterBody3D

@export var speed : float = 1
@export var friction : float = 0.9
@export var gravity : float = 0.55
@export var view_height : float = 1.75
@export var footstep_frequency : float = 4.75
@export var infight_group : Attack.INFIGHT_GROUP
@export var stun_time : int = 120
@export var pain_time : int = 30

@export var sfx_footsteps: AudioSettings = preload('res://audio/player/footsteps.tres')
@export var sfx_landings: AudioSettings = preload('res://audio/player/landings.tres')
@export var sfx_damage: AudioSettings = preload('res://audio/goon/damage.tres')
@export var sfx_attack: AudioSettings = preload('res://audio/goon/attack.tres')
@export var sfx_alert: AudioSettings = preload('res://audio/goon/alert.tres')
@export var sfx_death: AudioSettings = preload('res://audio/goon/death.tres')

var step_height_up : float = 1.1
var step_height_down : float = 1.1

var targetname : String
var activate_targetname : String
var start_disabled : bool

func enable_thing():
		visible = true
		process_mode = Node.PROCESS_MODE_INHERIT

func _func_godot_apply_properties( properties : Dictionary ):
	if not global.on_escape_check( properties ):
		queue_free()
		return

	if not properties.targetname.is_empty():
		global.targetname_add( properties.targetname, self )
		targetname = properties.targetname
	
	if not properties.target.is_empty():
		activate_targetname = properties.target

	if properties.flags & 4 != 0:
		start_disabled = true
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED

	if properties.flags & 8 != 0:
		speed = 0
		friction = 0

func do_target_activate( activator : Node3D ):
	if start_disabled:
		enable_thing()
	else:
		if global.check( self, "ai" ):
			self.ai.set_target( global.player )
