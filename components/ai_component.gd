extends Node
class_name AIComponent

@onready var parent : Node3D = get_parent()

@export var melee_range : float = 3.5
@export var melee_activation_range : float = 3.5
@export var melee_damage : float = 1
@export var melee_knockback : float = 25
@export var melee_delay_amount : int = 0
@export var melee_delay_randomness : int = 0

@export var attack_range : float = 200
@export var attack_activation_range : float = 200
@export var attack_damage : float = 1
@export var attack_knockback : float = 25
@export var attack_speed : float = 25
@export var attack_delay_amount : int = 30
@export var attack_delay_randomness : int = 30

@export var walk_angle_randomness : float = 0.25
@export var walk_backup_range : float  = 0
@export var walk_delay_amount : int = 10
@export var walk_delay_randomness : int = 60

var wakeup_delay : int = 60
var attack_delay : int = 60
var melee_delay : int = 60
var walk_delay : int
var walk_angle : float
var target : Node

func _physics_process( delta : float ):
	if wakeup_delay > 0:
		wakeup_delay -= 1
		return

	target = global.player
	
	if target != null and global.check( target, "health" ) and target.health.dead:
		target = null
	
	if parent.state.sticky_call_active:
		# count down generic delays
		
		if walk_delay > 0:
			walk_delay -= 1
		
		if attack_delay > 0:
			attack_delay -= 1

		if melee_delay > 0:
			melee_delay -= 1

func start_ai():
	global.enemy_list.append( parent )
	
	# has to do it after the enemies start up
	wakeup_delay = randf_range( 0, 60 )

	# important mechanic
	if global.check( parent, "sprite" ):
		parent.sprite.scale *= randf_range( 0.9, 1.1 )
		
		if randf_range( 1, 0 ) < 0.01:
			parent.sprite.flip_h = true
	
	parent.state.set_state( parent.state_active )

func generic_walk_direction() -> Vector3:
	if walk_delay <= 0:
		walk_angle = target_angle()
		if target_distance() > walk_backup_range:
			walk_angle += randf_range( -PI * walk_angle_randomness, PI * walk_angle_randomness )
		else:
			walk_angle += PI
		
		walk_delay = walk_delay_amount + randi_range( 0, walk_delay_randomness )
	
	return global.angle_to_direction( walk_angle ) * Vector3( 1, 0, 1 )

func target_direction() -> Vector3:
	return parent.global_position.direction_to( target.global_position )

func target_distance() -> float:
	return parent.global_position.distance_to( target.global_position )

func target_angle() -> float:
	var diff = parent.global_position - target.global_position
	return atan2( diff.x, diff.z )

func in_melee_range():
	return target_distance() < melee_range

func in_melee_activation_range():
	return target_distance() < melee_activation_range

func in_attack_range():
	return target_distance() < attack_range

func in_attack_activation_range():
	return target_distance() < attack_activation_range

func set_melee_delay():
	melee_delay = melee_delay_amount + randi_range( 0, melee_delay_randomness )

func set_attack_delay():
	attack_delay = attack_delay_amount + randi_range( 0, attack_delay_randomness )

func check_and_set_attack_states():
	if attack_delay <= 0 and in_attack_activation_range() and global.check( parent, "state_attack" ):
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
		attack.inflictor = null
		attack.parry_reaction = true
		target.health.do_damage( attack )
