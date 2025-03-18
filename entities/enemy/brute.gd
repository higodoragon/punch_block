extends CharacterBase
class_name EnemyBrute

@onready var health := $HealthComponent
@onready var hitbox := $HitboxComponent
@onready var physics := $CommonPhysicsComponent
@onready var state := $StateMachineComponent
@onready var ai := $AIComponent
@onready var audio := $AudioManagerComponent
@onready var sprite := $Sprite3D

var sfx_footstep = global.sfx_generic_footsteps

@export_range(1.0, 20.0) var charge_speed := 4.0
@export_range(1.0, 1000.0) var knockback: float = 80.0
@export_range(1.0, 1000.0) var charge_knockback: float = 400.0
@export_range(1.0, 50.0) var damage: float = 2.0
@export_range(1.0, 50.0) var charge_damage: float = 4.0
@export_range(1.0, 50.0, 0.1, 'suffix:m') var max_charge_distance: float = 10.0
@export_range(1.0, 50.0, 0.5) var charge_cooldown: float = 5.0
var _current_charge_cooldown := 0.0


var state_idle := [
	{sticky_call = "do_searth"},
	{delay = 1, frame = 0},
	{goto = state_active}
]

var state_active := [
	{sticky_call = "do_active"},
	{delay = 15, frame = 1},
	{delay = 15, frame = 2},
	{loop = true}
]

var state_charge := [
	{sticky_call = "do_charge"},
	{delay = 15, frame = 6},
	{delay = 15, frame = 5},
	{loop = true}
]

var state_melee := [
	{sticky_call = "do_melee_active"},
	{delay = 20, frame = 3},
	{delay = 1, frame = 4},
	{sticky_call = ""},
	{call = "do_melee"},
	{delay = 20, frame = 5},
	{goto = state_active},
]

var state_stun := [
	{delay = 120, frame = 6},
	{goto = state_active},
]

func _ready() -> void:
	ai.start_ai()

func do_active():
	if ai.target:
		do_move_toward()

		if should_charge():
			do_charge()


## approach the target to get within charging distance
func do_move_toward():
		var angle = ai.target_angle()
		var walk: Vector3 = global.angle_to_direction(angle) * Vector3(1, 0, 1)
		velocity += walk * speed


# func do_melee_active():
# 	if ai.target:
# 		do_charge()
		# var walk: Vector3 = ai.target_direction() * Vector3(1, 0, 1)
		# velocity += walk * (speed * 2)

func do_melee():
	if ai.target and ai.in_melee_range():
		hit(damage, knockback)


func do_parry_reaction(inflictor: Node3D):
	state.set_state(state_stun)

func _physics_process(delta: float):
	physics.common_physics(delta)
	_current_charge_cooldown -= delta

func do_charge():
	state.set_state(state_charge)
	print('CHARGING')
	if ai.target and should_charge():
		if ai.in_melee_activation_range():
			hit(charge_damage, charge_knockback)
		global_position = global_position.move_toward(ai.target.global_position, charge_speed * get_physics_process_delta_time())
	else:
		state.set_state(state_active)
		do_active()

var attack_delay = 100
var melee_delay = 100

func should_attack():
	# if attack_delay <= 0 and global.check( parent, "state_attack" ):
	# 	state.set_state( state_attack )
	# 	return true
	if melee_delay <= 0 and ai.in_melee_activation_range() and global.check(self, "state_melee"):
		state.set_state(state_melee)
		return true

func should_charge():
	# if attack_delay <= 0 and global.check( parent, "state_attack" ):
	# 	state.set_state( state_attack )
	# 	return true
	# if melee_delay <= 0 and ai.target and global_position:
	# 	return true
	if _current_charge_cooldown <= 0.0 and (global_position.distance_to(ai.target.global_position) < max_charge_distance):
		return true


func hit(hit_dmg: float, hit_knock: float):
	if ai.target and ai.in_melee_range():
		_current_charge_cooldown = charge_cooldown
		
		var atk = Attack.new()
		atk.agressor = self
		atk.knockback_power = hit_knock
		atk.damage = hit_dmg
		combat.hitscan_bullet(self, global_position, ai.target_direction(), atk)
		ai.attack_delay = 100
