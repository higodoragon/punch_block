extends CharacterBase

@onready var health : HealthComponent = $HealthComponent
@onready var hitbox : HitboxComponent = $HitboxComponent
@onready var physics : CommonPhysicsComponent = $CommonPhysicsComponent
@onready var state : StateMachineComponent = $StateMachineComponent
@onready var ai : AIComponent = $AIComponent
@onready var audio : AudioManagerComponent = $AudioManagerComponent
@onready var sprite : Sprite3D = $Sprite3D

var sfx_footstep = global.sfx_generic_footsteps

var state_idle := [
	{ delay = 1, frame = 0 },
	{ loop = true }
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

var state_stun := [
	{ delay = 240, frame = 7 },
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
		attack.damage = ai.attack_damage
		attack.knockback_power = ai.attack_knockback
		attack.parry_reaction = true
		combat.fire_projectile( self, global_position, ai.target_direction(), ai.attack_speed, attack )
		ai.set_attack_delay()

func _physics_process( delta : float ):
	physics.common_physics( delta )
