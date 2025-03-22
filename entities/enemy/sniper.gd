extends CharacterBase
class_name EnemySniper

@onready var health : HealthComponent = $HealthComponent
@onready var hitbox : HitboxComponent = $HitboxComponent
@onready var physics : CommonPhysicsComponent = $CommonPhysicsComponent
@onready var state : StateMachineComponent = $StateMachineComponent
@onready var ai : AIComponent = $AIComponent
@onready var audio : AudioManagerComponent = $AudioManagerComponent
@onready var sprite : Sprite3D = $Sprite3D

@onready var laser_head = $LaserHead
@onready var laser_material = $LaserHead/LaserMesh.get_active_material( 0 )

@export var sfx_warning : AudioSettings

var state_idle := [
	{ delay = -1, frame = 0 },
]

var state_active := [
	{ sticky_call = "do_active" },
	{ delay = 15, frame = 1 },
	{ delay = 15, frame = 2 },
	{ loop = true }
]

var state_attack_real := [
	{ call = "do_attack_real" },
	{ delay = 20, frame = 5 },
	{ goto = state_active },
]

var state_attack := [
	{ call = "do_beep" },
	{ delay = 60, frame = 4 },
	{ goto = state_attack_real },
]

var state_stun := [
	{ delay = -1, frame = 7 },
]

var state_pain := [
	{ delay = -1, frame = 6 },
]

func _ready():
	view_height = 1
	ai.start_ai()

func _physics_process(delta):
	physics.common_physics(delta)

func _process( delta ):
	# lazer animation and tracking
	if ai.target:
		var result = ai.target_line_of_sight_result()
		var hit_position := Vector3.ZERO
				
		if not result.is_empty():
			hit_position = result.position - Vector3( 0, view_height, 0 )
		else:
			hit_position = ai.target.global_position

		laser_head.position = Vector3.ZERO
		laser_head.look_at( hit_position )
		laser_head.scale.z = global_position.distance_to( hit_position )
		laser_head.position = Vector3( 0, view_height, 0 )
		if state.current_array == state_attack:
			laser_material.albedo_color = Color.WHITE
		else:
			laser_material.albedo_color = Color8( 255, 23, 105 )
		laser_head.show()
	else:
		laser_head.hide()

func do_active():
	if ai.target:
		velocity += ai.generic_walk_direction() * speed
		ai.check_and_set_attack_states()

func do_beep():
	if ai.target:
		var audio_player = audio.play( sfx_warning )

func do_attack_real():
	if ai.target:
		var attack := Attack.new()
		attack.agressor = self
		attack.damage = ai.attack_damage
		attack.knockback_power = ai.attack_knockback
		combat.hitscan_bullet( self, global_position, ai.target_direction(), attack )
		ai.set_attack_delay()
		
		var audio_player = audio.play( sfx_attack )
		audio_player.process_mode = Node.PROCESS_MODE_ALWAYS # plays though frezee frame
		audio_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
