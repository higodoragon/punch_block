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
var real_footstep_frequency : int

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
	{call = "do_attack_warning"},
	{delay = 30, frame = 3},
	{goto = state_attack_charge},
]

var state_melee := [
	{sticky_call = "do_melee_sticky"},
	{call = "do_melee_warning"},
	{delay = 45, frame = 6},
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
	real_footstep_frequency = footstep_frequency
	real_friction = friction
	ai.start_ai()

func do_active():
	if ai.target:
		velocity += ai.generic_walk_direction() * speed
		ai.check_and_set_attack_states()

func do_melee_sticky():
	pass

func do_melee_warning():
	var audio_player : AudioStreamPlayer3D = audio.play( sfx_attack )
	audio_player.pitch_scale = 1
	audio_player.volume_linear += 0.25

func do_melee():
	if ai.target:
		if ai.in_melee_range():
			hit( ai.melee_damage )
		ai.set_melee_delay()

	var audio_player : AudioStreamPlayer3D = audio.play( sfx_attack )
	audio_player.pitch_scale = 1.25
	audio_player.volume_linear += 0.25

func do_attack_warning():
	var audio_player : AudioStreamPlayer3D = audio.play( sfx_attack )
	audio_player.pitch_scale = 0.90
	audio_player.volume_linear += 0.25

func do_attack_sticky():
	if ai.target:
		var vertical_distance = absf( self.global_position.y - ai.target.global_position.y )
		var horizontal_distance = Vector2( self.global_position.x, self.global_position.z ).distance_to( Vector2( ai.target.global_position.x, ai.target.global_position.z ) )
		
		if horizontal_distance < 2:
			# try to hit the player
			if vertical_distance < 2:
				var hit_result : AttackResult = hit( ai.attack_damage )
				if hit_result.was_parried:
					# was parried
					velocity = global.angle_to_direction( ai.target_angle() ) * -50
					state.set_state( state_attack_counter )
				else:
					# did hit
					if ai.target.velocity.y < 0:
						ai.target.velocity.y = 0
					ai.target.velocity.y += 20	
					state.set_state( state_attack_hit )
					audio.play( sfx_attack )
			else:
				# missed
				state.set_state( state_attack_hit )
				audio.play( sfx_attack )
							
			# sets both to avoid them activating melee
			# right after hitting the player
			wall_delay = 0
			ai.set_attack_delay()
			ai.set_melee_delay()
			
		else:
			if is_on_wall():
				wall_delay += 1
				if wall_delay > 15:
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
				if victim == ai.target or victim.velocity.y > 0 or victim is EnemyBrute:
					# ignore on charge
					continue
					
				global.stun( victim, 60, true )
				victim.velocity.y = 18
				victim.velocity.x = 0
				victim.velocity.z = 0

				var attack = Attack.new()
				attack.agressor = self
				attack.damage = 2 # much less damage, just enough to instakill a goon
				attack.knockback_power = 0
				attack.knockback_position = global_position
					
				global.damage( victim, attack )
					
				audio.play( sfx_attack )

			# friction is changed while charing
			var new_velocity = global.angle_to_direction( ai.target_angle() ) * 48
			velocity.x = new_velocity.x
			velocity.z = new_velocity.z
	else:
		state.set_state( state_active )

func hit( hit_damage: float ) -> AttackResult:
	var attack = Attack.new()
	attack.agressor = self
	attack.damage = hit_damage
	attack.knockback_power = 0
	attack.knockback_position = global_position

	var attack_result : AttackResult = global.damage( ai.target, attack )
	var knockback_power = 100

	if attack_result.was_parried:
		# counter!
		knockback_power = 50

	ai.target.velocity = global.angle_to_direction( ai.target_angle() ) * knockback_power

	return attack_result

func _physics_process( delta: float ):
	if state.current_array == state_attack_charge:
		# clip though enemies
		collision_mask = 1
		collision_layer = 0
		footstep_frequency = 5
		friction = 0.5
	else:
		footstep_frequency = real_footstep_frequency
		friction = real_friction
		collision_mask = old_collision_mask
		collision_layer = old_collision_layer
		
	physics.common_physics( delta )
