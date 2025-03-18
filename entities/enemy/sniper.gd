extends CharacterBase
class_name EnemySniper

@onready var health: HealthComponent = $HealthComponent
@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var sprite: Sprite3D = $Sprite3D
@onready var physics: CommonPhysicsComponent = $CommonPhysicsComponent
@onready var ai: AIComponent = $AIComponent
@onready var state: StateMachineComponent = $StateMachineComponent
@onready var parent: Node3D = get_parent()
@onready var laser_head : Node3D = $LaserHead
@onready var laser_mat = $LaserHead/LaserMesh.get_active_material(0)
@onready var audio: AudioManagerComponent = $AudioManagerComponent


@export_group('Sniper-Specific Settings')
@export_range(1, 100) var damage: int = 5
@export var knockback: float = 100.0
@export var backup_distance: float = 12.0
@export var stun_time: float = 40.0
@export var projectile_velocity := 10.0
@export var weapon_range: float = 100.0
@export var time_to_fire: float = 10.0
@onready var _time_to_fire_cooldown: float = time_to_fire
@export var beep: AudioSettings

var sfx_footstep = global.sfx_generic_footsteps
var last_known_pos: Vector3

var state_pain := [
	{ delay = stun_time, frame = 6 },
	{ goto = state_active }
]

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
	{ sticky_call = "" },
	{ delay = 10, frame = 4 },
	{ call = "do_attack" },
	{ delay = 20, frame = 5 },
	{ delay = 1, frame = 4 },
	{ goto = state_active },
]

const state_about_to_attack := [
	{ sticky_call = "" },
	{ delay = 0, frame = 0 },
	{ call = "do_about_to_attack" },
	{ loop = false },
	# { goto = state_attack },
]

func _ready():
	ai.start_ai()

func _physics_process(delta):
	physics.common_physics(delta)

func _process( delta ):
	if ai.target:
		_time_to_fire_cooldown -= delta
	
		var target_position : Vector3 = ai.target.global_position
		
		if ai.target == global.player:
			target_position = ai.target.camera.global_position - Vector3( 0, ai.target.view_height, 0 ) - Vector3( 0, view_height, 0 )

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.new()
		query.collide_with_areas = false
		query.collide_with_bodies = true
		query.from = global_position + Vector3( 0, 1, 0 )
		query.to = ai.target.global_position + Vector3( 0, 1, 0 )
		query.collision_mask = 1

		var result = space_state.intersect_ray( query )
		var hit_position := Vector3.ZERO
		
		if not result.is_empty():
			hit_position = result.position - Vector3( 0, 1, 0 )
		else:
			hit_position = ai.target.global_position
		
		laser_head.position = Vector3.ZERO
		laser_head.look_at( hit_position )
		laser_head.scale.z = global_position.distance_to( hit_position )
		laser_head.position = Vector3( 0, 1, 0 )
		laser_head.show()
	else:
		laser_head.hide()

func do_move():
	if ai.walk_angle_time <= 0:
		ai.walk_angle = ai.target_angle()
		if ai.target_distance() > backup_distance:
			ai.walk_angle += randf_range( -PI * 0.25, PI * 0.25 )
		else:
			ai.walk_angle += PI
		ai.walk_angle_time = randi_range(30, 60)
	
	var walk: Vector3 = global.angle_to_direction(ai.walk_angle) * Vector3(1, 0, 1)
	velocity += walk * speed

func do_active():
	if ai.target:
		do_move()
		if _time_to_fire_cooldown <= 1.0:
			# FIXME this is getting called twice and i don't know why
			print('?')
			state.set_state(state_about_to_attack)
		# ai.should_attack()

func do_attack():
	if ai.target and _time_to_fire_cooldown <= 0.0:
		attack()

func do_about_to_attack():
	# FIXME this is getting called twice and i don't know why
	print('!')
	laser_mat.albedo_color = Color.WHITE
	for i in range(3):
		global.audio_play_at(beep, global_position)
		await get_tree().create_timer(0.3333).timeout
	state.set_state(state_attack)


func attack():
	_time_to_fire_cooldown = time_to_fire
	var attack := Attack.new()
	attack.agressor = self
	attack.damage = damage
	attack.knockback_power = knockback
	combat.hitscan_bullet( self, global_position, ai.target_direction(), attack )
	# ai.attack_delay = 100
	laser_mat.albedo_color =  Color.RED
