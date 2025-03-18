extends CharacterBase

@onready var health := $HealthComponent
@onready var hitbox := $HitboxComponent
@onready var physics := $CommonPhysicsComponent
@onready var state := $StateMachineComponent
@onready var ai := $AIComponent
@onready var audio := $AudioManagerComponent
@onready var sprite := $Sprite3D

@export var projectile_damage = 3.5
@export var projectile_knockback = 40
@export var projectile_velocity = 20

@export var backup_distance = 10

var sfx_footstep = global.sfx_generic_footsteps

var state_idle := [
	{ sticky_call = "do_searth" },
	{ delay = 1, frame = 0 },
	{ goto = state_active }
]

var state_active := [
	{ sticky_call = "do_active" },
	{ delay = 15, frame = 1 },
	{ delay = 15, frame = 2 },
	{ loop = true }
]

var state_attack := [
	{ sticky_call = "do_attack_active" },
	{ delay = 20, frame = 3 },
	{ delay = 1, frame = 4 },
	{ sticky_call = "" },
	{ call = "do_attack" },
	{ delay = 20, frame = 5 },
	{ goto = state_active },
]

var state_pain := [
	{ delay = 10, frame = 6 },
	{ goto = state_active },
]

func _ready() -> void:
	ai.start_ai()

func do_active():
	if ai.target:
		velocity += ai.generic_walk_direction() * speed
		ai.check_and_set_attack_states()

func do_attack_active():
	if ai.target:
		velocity += ai.generic_walk_direction() * speed

func do_attack():
	if ai.target:
		var attack := Attack.new()
		attack.agressor = self
		attack.inflictor = null
		attack.damage = projectile_damage
		attack.knockback_power = projectile_knockback
		attack.parry_reaction = true
		combat.fire_projectile( self, global_position, ai.target_direction(), projectile_velocity, attack )
		ai.set_attack_delay()

func _physics_process( delta : float ):
	physics.common_physics( delta )
