extends Node
class_name HealthComponent

@onready var parent : Node3D = get_parent()

@export var max_health : float = 10
var health : float
@export var iframes_amount : int = 0
var iframes : int = 0
@export var knockback_multiplier : float = 1

var dead : bool = false

func _ready():
	health = max_health

func _physics_process(delta: float) -> void:
	if iframes_amount > 0:
		iframes -= 1

func do_damage( attack : Attack ):

	if parent is Player and not attack.ignore_blocking:
		parent.do_block_damage( attack )
		return

	if global.check( parent, "infight_group" ) and parent.infight_group != 0 and parent.infight_group == attack.infight_group:
		return

	if global.check( parent, "velocity" ):
		var damage_push = attack.knockback_position.direction_to( parent.global_position )
		damage_push *= attack.knockback_power * knockback_multiplier
		damage_push.y = 0
		parent.velocity += damage_push

	if iframes > 0:
		return

	elif global.check( parent, "state" ) and global.check( parent, "state_pain" ):
		parent.state.set_state( parent.state_pain )
	
	if not attack.is_silent and global.check( parent, "audio" ):
		if attack.damage > 0:
			if global.check( parent, "sfx_hurt" ):
				parent.audio.play( parent.sfx_hurt )
			else:
				parent.audio.play( global.sfx_generic_hurt )
		else:
			# TODO: BLOCK SFX
			pass

	health -= attack.damage
	
	iframes = iframes_amount
	
	if health <= 0 and not dead:
		if attack.agressor != null:
			global.kill( parent, attack.agressor )
		else:
			global.kill( parent )
