extends Node

@onready var parent : Node3D = get_parent()

var wakeup_delay : int = 60
var attack_delay : int = 60
var melee_delay : int = 60
var walk_angle : float
var walk_angle_time : int

@export var melee_range : float = 3.5
@export var melee_activation_range : float = 3.5
@export var melee_damage : float = 2
@export var melee_knockback : float = 25
@export var walk_angle_randomness = 0

var target : Node

func target_direction() -> Vector3:
	if target:
		return parent.global_position.direction_to( target.global_position )
	
	return Vector3( 1, 0, 0 )

func target_distance() -> float:
	return parent.global_position.distance_to( target.global_position )

func target_angle() -> float:
	var diff = parent.global_position - target.global_position
	return atan2( diff.x, diff.z )

func in_melee_range():
	return target_distance() < melee_range

func in_melee_activation_range():
	return target_distance() < melee_activation_range

func should_attack():
	if attack_delay <= 0 and global.check( parent, "state_attack" ):
		parent.state.set_state( parent.state_attack )
		return true

	if melee_delay <= 0 and in_melee_activation_range() and global.check( parent, "state_melee" ):
		parent.state.set_state( parent.state_melee )
		return true
		
	return false

func generic_melee():
	if in_melee_range():
		var attack := Attack.new()
		attack.damage = melee_damage
		attack.knockback_power = melee_knockback
		attack.knockback_position = parent.global_position
		attack.agressor = parent
		target.health.do_damage( attack )

func start_ai():
	# has to do it after the enemies start up
	wakeup_delay = randf_range( 0, 60 )
	attack_delay = randf_range( 10, 20 )

	# important mechanic
	if global.check( parent, "sprite" ):
		parent.sprite.scale *= randf_range( 0.9, 1.1 )
	
	parent.state.set_state( parent.state_active )

func _physics_process( delta : float ):
	if wakeup_delay > 0:
		wakeup_delay -= 1
		return

	target = global.player
	
	if target != null:
		if global.check( target, "health" ) and target.health.dead:
			target = null
	
	if attack_delay > 0:
		attack_delay -= 1

	if melee_delay > 0:
		melee_delay -= 1
		
	if walk_angle_time > 0:
		walk_angle_time -= 1
