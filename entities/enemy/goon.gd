extends CharacterBase
class_name EnemyGoon

@onready var health : HealthComponent = $HealthComponent
@onready var hitbox : HitboxComponent = $HitboxComponent
@onready var physics : CommonPhysicsComponent = $CommonPhysicsComponent
@onready var state : StateMachineComponent = $StateMachineComponent
@onready var ai : AIComponent = $AIComponent
@onready var audio : AudioManagerComponent = $AudioManagerComponent
@onready var sprite : Sprite3D = $Sprite3D

var state_idle := [
	{ delay = -1, frame = 0 },
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

var state_stun := [
	{ delay = -1, frame = 7 },
]

var state_pain := [
	{ delay = -1, frame = 6 },
]

func _ready() -> void:
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
		ai.generic_melee()
		ai.set_melee_delay()

func do_block_reaction( inflictor : Node3D, is_parry : bool ):
	var radious = 10
	if is_parry:
		radious = 20
		
	for e in global.enemy_list:
		if e == null:
			continue

		if not ai.line_of_sight_result( global_position, e.global_position ):
			global.stun( e )

func _physics_process( delta : float ):
	physics.common_physics( delta )
