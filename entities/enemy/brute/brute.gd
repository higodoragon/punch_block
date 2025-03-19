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
var real_friction : float

var state_idle := [
	{sticky_call = "do_searth"},
	{delay = 1, frame = 0},
	{goto = state_active},
]

var state_active := [
	{sticky_call = "do_active"},
	{delay = 15, frame = 1},
	{loop = true},
]

var state_attack_charge := [
	{sticky_call = "do_attack_sticky"},
	{delay = 30, frame = 6},
	{loop = true},
]

var state_attack_hit := [
	{delay = 20, frame = 5},
	{goto = state_active},
]

var state_attack := [
	{delay = 30, frame = 6},
	{goto = state_attack_charge},
]

var state_melee := [
	{delay = 20, frame = 3},
	{delay = 1, frame = 4},
	{call = "do_melee"},
	{delay = 20, frame = 5},
	{goto = state_active},
]

var state_stun := [
	{delay = 240, frame = 6},
	{goto = state_active},
]

func _ready() -> void:
	real_friction = friction
	ai.start_ai()

func do_active():
	if ai.target:
		velocity += ai.generic_walk_direction() * speed
		ai.check_and_set_attack_states()

func do_melee_active():
	if ai.target:
		velocity += ai.generic_walk_direction() * ( speed * 1.5 )

func do_melee():
	if ai.target:
		hit( ai.melee_damage, ai.melee_knockback )
		ai.set_melee_delay()

func do_attack_sticky():
	if ai.target:
		if ai.in_melee_range():
			hit( ai.attack_damage, ai.attack_knockback )
			state.set_state( state_attack_hit )
			# sets both to avoid them activating melee
			# right after hitting the player
			ai.set_attack_delay()
			ai.set_melee_delay()
			# sets friction back to the original value
			friction = real_friction
		else:
			velocity.x =+ ai.target_direction().x * 48
			velocity.z =+ ai.target_direction().z * 48
			friction = 0.5
	else:
		friction = real_friction
		state.set_state( state_active )

func hit( hit_damage: float, hit_knockback: float ):
	var attack = Attack.new()
	attack.agressor = self
	attack.damage = hit_damage
	attack.knockback_power = hit_knockback
	attack.knockback_position = global_position
	ai.target.health.do_damage( attack )
	ai.target.velocity.y = 20

func do_block_reaction( inflictor: Node3D, is_parry : bool ):
	state.set_state(state_stun)

func _physics_process( delta: float ):
	physics.common_physics( delta )
