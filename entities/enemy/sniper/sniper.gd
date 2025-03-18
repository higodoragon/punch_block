extends CharacterBase

@onready var health : HealthComponent = $HealthComponent
@onready var hitbox : HitboxComponent = $HitboxComponent
@onready var physics : CommonPhysicsComponent = $CommonPhysicsComponent
@onready var state : StateMachineComponent = $StateMachineComponent
@onready var ai : AIComponent = $AIComponent
@onready var audio : AudioManagerComponent = $AudioManagerComponent
@onready var sprite : Sprite3D = $Sprite3D

@onready var laser_head = $LaserHead
@onready var laser_material = $LaserHead/LaserMesh.get_active_material( 0 )

var sfx_footstep = global.sfx_generic_footsteps

#var state_pain := [
#	{ delay = stun_time, frame = 6 },
#	{ goto = state_active }
#]

const state_idle := [
	{ sticky_call = "do_searth" },
	{ delay = 1, frame = 0 },
	{ goto = state_active }
]

const state_active := [
	{ sticky_call = "do_active" },
	{ delay = 15, frame = 1 },
	{ delay = 15, frame = 2 },
	{ loop = true }
]

const state_attack := [
	{ delay = 10, frame = 4 },
	{ call = "do_attack" },
]

const state_attack_real := [
	{ call = "do_attack_real" },
	{ delay = 20, frame = 5 },
	{ goto = state_active },
]

func _ready():
	view_height = 1
	ai.start_ai()

func _physics_process(delta):
	physics.common_physics(delta)

func _process( delta ):
	# lazer animation and tracking
	if ai.target:
		var result = sniper_hitscan_result()
		var hit_position := Vector3.ZERO
				
		if not result.is_empty():
			hit_position = result.position - Vector3( 0, view_height, 0 )
		else:
			hit_position = ai.target.global_position
		
		laser_head.position = Vector3.ZERO
		laser_head.look_at( hit_position )
		laser_head.scale.z = global_position.distance_to( hit_position )
		laser_head.position = Vector3( 0, view_height, 0 )
		laser_head.show()
	else:
		laser_head.hide()

func sniper_hitscan_result():
	if ai.target:
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.new()
		query.collide_with_areas = false
		query.collide_with_bodies = true
		query.from = global_position + Vector3( 0, view_height, 0 )
		query.to = ai.target.global_position + Vector3( 0, view_height, 0 )
		query.collision_mask = 1
		
		return space_state.intersect_ray( query )
	else:
		return null


func do_active():
	if ai.target:
		velocity += ai.generic_walk_direction() * speed
		ai.check_and_set_attack_states()

func do_attack():
	if ai.target:
		laser_material.albedo_color = Color.WHITE
		for i in range( 3 ):
			audio.play( global.sfx_sniper_beep )
			await get_tree().create_timer( 0.3333 ).timeout
		state.set_state( state_attack_real )

func do_attack_real():
	if ai.target:
		laser_material.albedo_color =  Color.RED
		var attack := Attack.new()
		attack.agressor = self
		attack.damage = ai.attack_damage
		attack.knockback_power = ai.attack_knockback
		combat.hitscan_bullet( self, global_position, ai.target_direction(), attack )
		ai.set_attack_delay()
