extends CharacterBase
class_name EnemyBrute

@onready var health := $HealthComponent
@onready var hitbox := $HitboxComponent
@onready var physics := $CommonPhysicsComponent
@onready var state := $StateMachineComponent
@onready var ai := $AIComponent
@onready var audio := $AudioManagerComponent
@onready var sprite := $Sprite3D
@onready var collision : CollisionShape3D = $CollisionShape3D

var real_friction : float
var old_collision_mask : int = collision_mask
var old_collision_layer : int = collision_layer
var wall_delay : int = 0

var state_idle := [
	{ delay = -1, frame = 0 },
]

var state_active := [
	{sticky_call = "do_active"},
	{ delay = 30, frame = 1 },
	{ delay = 30, frame = 2 },
	{loop = true},
]

var state_attack_counter := [
	{delay = 30, frame = 3},
	{goto = state_active},
]

var state_attack_hit := [
	{delay = 20, frame = 7},
	{goto = state_active},
]

var state_attack_charge := [
	{sticky_call = "do_attack_sticky"},
	{delay = 10, frame = 4},
	{delay = 10, frame = 5},
	{loop = true},
]

var state_attack := [
	{delay = 30, frame = 3},
	{goto = state_attack_charge},
]

var state_melee := [
	{delay = 35, frame = 6},
	{call = "do_melee"},
	{delay = 20, frame = 7},
	{goto = state_active},
]

var state_stun := [
	{ delay = -1, frame = 9 },
]

var state_pain := [
	{ delay = -1, frame = 8 },
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
		if ai.in_melee_range():
			hit( ai.melee_damage )
		ai.set_melee_delay()

func do_attack_sticky():
	if ai.target:
		if ai.target_distance() < 2:
			var hit_result : AttackResult = hit( ai.attack_damage )
			if hit_result.was_parried:
				# counter!
				velocity = global.angle_to_direction( ai.target_angle() ) * -50
				state.set_state( state_attack_counter )
			else:
				if ai.target.velocity.y < 0:
					ai.target.velocity.y = 0
				ai.target.velocity.y += 20	
				state.set_state( state_attack_hit )
							
			# sets both to avoid them activating melee
			# right after hitting the player
			wall_delay = 0
			ai.set_attack_delay()
			ai.set_melee_delay()
			
		else:
			if is_on_wall():
				wall_delay += 1
				if wall_delay > 30:
					# stop if you hit a wall
					ai.set_attack_delay()
					state.set_state( state_active )
					velocity.x = 0
					velocity.y = 0
					return
			else:
				wall_delay = 0

			# run over enemies >:3

			var query = PhysicsShapeQueryParameters3D.new()
			query.collide_with_areas = true
			query.collide_with_bodies = false
			query.collision_mask = 16
			query.exclude = [ hitbox ]
			query.shape = collision.shape
			query.transform = collision.global_transform
			var result = global.stage.get_world_3d().direct_space_state.intersect_shape( query, 32 )
			
			for r in result:
				var victim = r.collider.parent
				if victim != ai.target and victim.velocity.y <= 0:
					global.stun( victim, 60, true )
					victim.velocity.y = 18
					victim.velocity.x = 0
					victim.velocity.z = 0

					var attack = Attack.new()
					attack.agressor = self
					attack.damage = 2 # much less damage, just enough to instakill a goon
					attack.knockback_power = 0
					attack.knockback_position = global_position
					
					if global.check( victim, "health" ):
						victim.health.do_damage( attack )

			# friction is changed while charing
			velocity.x =+ ai.target_direction().x * 48
			velocity.z =+ ai.target_direction().z * 48
	else:
		state.set_state( state_active )

func hit( hit_damage: float ) -> AttackResult:
	ai.target.velocity = global.angle_to_direction( ai.target_angle() ) * ai.attack_knockback

	var attack = Attack.new()
	attack.agressor = self
	attack.damage = hit_damage
	attack.knockback_power = 0
	attack.knockback_position = global_position
	return ai.target.health.do_damage( attack )

func do_block_reaction( inflictor: Node3D, is_parry : bool ):
	state.set_state(state_stun)

func _physics_process( delta: float ):
	if state.current_array == state_attack_charge:
		# clip though enemies
		collision_mask = 1
		collision_layer = 0
		friction = 0.5
	else:
		friction = real_friction
		collision_mask = old_collision_mask
		collision_layer = old_collision_layer
		
	physics.common_physics( delta )
