extends Node
class_name HealthComponent

@onready var parent : Node3D = get_parent()

@export var max_health : float = 10
var health : float:
	set(val):
		health = clampf(val, 0.0, max_health)
		health_updated.emit(health)

@export var iframes_amount : int = 0
var iframes : int = 0
@export var knockback_multiplier : float = 1

var dead : bool = false
signal health_updated(val)

func _ready():
	health = max_health

func _physics_process(delta: float) -> void:
	if iframes_amount > 0:
		iframes -= 1

func do_damage( attack : Attack ) -> AttackResult:

	var attack_result = AttackResult.new()

	if parent is Player and not attack.ignore_blocking:
		return parent.do_block_damage( attack, attack_result )

	if global.check( parent, "infight_group" ) and parent.infight_group != 0 and parent.infight_group == attack.infight_group:
		attack_result.was_ignored = true
		return attack_result

	if global.check( parent, "velocity" ):
		var damage_push = attack.knockback_position.direction_to( parent.global_position )
		damage_push *= attack.knockback_power * knockback_multiplier
		damage_push.y = 0
		parent.velocity += damage_push

	if iframes > 0:
		attack_result.was_ignored = true
		return attack_result

	if global.check( parent, "ai" ) and parent.ai.stun_time <= 0 and global.check( parent, "state" ):
		global.stun( parent, -1, true )

	health -= attack.damage
	iframes = iframes_amount
	
	if health <= 0 and not dead:
		attack_result.did_kill = true
		
		if attack.agressor != null:
			global.kill( parent, attack.agressor )
		else:
			global.kill( parent )
	else:
		parent.audio.play( parent.sfx_damage )
	
	return attack_result
