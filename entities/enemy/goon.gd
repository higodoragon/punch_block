extends CharacterBase

@onready var health := $HealthComponent
@onready var hitbox := $HitboxComponent
@onready var physics := $CommonPhysicsComponent
@onready var state := $StateMachineComponent
@onready var ai := $AIComponent
@onready var audio := $AudioManagerComponent
@onready var sprite := $Sprite3D

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

var state_melee := [
	{ sticky_call = "do_melee_active" },
	{ delay = 20, frame = 3 },
	{ delay = 1, frame = 4 },
	{ sticky_call = "" },
	{ call = "do_melee" },
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
		var angle = ai.target_angle()
		var walk : Vector3 = global.angle_to_direction( angle ) * Vector3( 1, 0, 1 )
		velocity += walk * speed

		ai.should_attack()

func do_melee_active():
	if ai.target:
		var walk : Vector3 = ai.target_direction() * Vector3( 1, 0, 1 )
		velocity += walk * ( speed * 2 )

func do_melee():
	if ai.target:
		ai.generic_melee()
		ai.melee_delay = 60

func _physics_process( delta : float ):
	physics.common_physics( delta )
