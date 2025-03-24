class_name Player extends CharacterBase

@onready var health: HealthComponent = $HealthComponent
@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var physics: CommonPhysicsComponent = $CommonPhysicsComponent
@onready var audio: AudioManagerComponent = $AudioManagerComponent

@onready var camera: Camera3D = $Camera3D
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var interface: CanvasLayer = $Interface
@onready var hud: Control = $Interface/HUD
@onready var hud_crosshair: TextureRect = $Interface/HUD/Crosshair
@onready var hud_health: Label = $Interface/HUD/HealthLabel
@onready var hud_power: Label = $Interface/HUD/PowerLabel
@onready var hud_message: RichTextLabel = $Interface/HUD/Messages
@onready var hud_debug_block: Label = $Interface/HUD/BlockStateLabel
@onready var hud_debug_action: Label = $Interface/HUD/ActionDelayLabel

@export var jump_power: float = 10
@export var jump_buffer_base: int = 15
var jump_buffer_time: int = 0
@export var jump_cayote_base: int = 20
var jump_cayote_time: int = 0
var view_step_offset: float = 0
@export var view_step_smooth: float = 20
@export var hp_steal_mult := 0.2

var target: Node3D

# ANIMATION vars
@onready var viewmodel: Node3D = $ViewmodelHead
@onready var viewmodel_animation: AnimationPlayer = $ViewmodelHead/Viewmodel/AnimationPlayer
@onready var bracelet: MeshInstance3D = $ViewmodelHead/Viewmodel/Armature/Skeleton3D/Cylinder
@onready var bracelet_material: ShaderMaterial

@export var sfx_parry: AudioSettings
@export var sfx_block: AudioSettings
@export var sfx_jump: AudioSettings

var magic_max: int = 60 * 60
var magic: int = magic_max:
	set(val):
		magic = val
		magic_updated.emit(magic)

signal magic_updated(val)

var ring_shader = preload('res://shader_material_ring.tres')

var power_max: int = 60 * 4
var power: int = power_max

# BLOCK vars
var action_delay: int = 0

var block_time: int = 0
var block_amount: int = 0
var block_did_a_parry: bool = false

var block_press_old: bool = false
var block_press: bool = false
var block_input: bool = false
var block_active: bool = false
var parry_active: bool = false
var block_buffer: int = 0
var did_parry: bool = false
var parrycombo_amount: int = 0
var parrycombo_time: int = 0

const parry_frametime = 15

# PUNCH vars
const punch_time_delay: int = 10
const punch_time_recovery: int = 30
var punch_should_be_right: bool = true

const punch_animation_start := punch_time_delay + punch_time_recovery
const punch_animation_hit := punch_time_recovery

var punch_buffer: int = 0
var punch_animation: int = 0

func _ready():
	# animation stuff
	viewmodel_animation.animation_finished.connect(viewmodel_finished_animation)
	viewmodel_play_animation("idle")
	
	# i'm ugly and i'm proud
	# bracelet.mesh.surface_set_material(0, bracelet_material.duplicate())
	bracelet.mesh.surface_set_material(0, ring_shader)
	bracelet_material = bracelet.mesh.surface_get_material(0)

func viewmodel_move_to_camera():
	viewmodel.global_position = camera.global_position
	viewmodel.global_rotation = camera.global_rotation
	
func viewmodel_finished_animation(animation_name: String):
	if animation_name == "die":
		return
	
	if animation_name == "hold_on" or animation_name == "hold_block":
		return

	if animation_name == "idle":
		return
	
	viewmodel_play_animation("idle")

func viewmodel_play_animation(animation: StringName):
	viewmodel_animation.stop()
	viewmodel_animation.play(animation)

func view_direction() -> Vector3:
	return global.rotation_to_direction(Vector3(camera.rotation.x, global_rotation.y, 0))

func on_parry_frametime():
	return block_time < parry_frametime

func _input( event: InputEvent ):
	if health.dead:
		return
	
	if Input.is_action_pressed("action_block"):
		block_buffer = 20

	if Input.is_action_just_pressed("action_punch"):
		punch_buffer = 20

	if event is InputEventMouseMotion:
		if not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: return
		var mouse_look: Vector2 = - event.relative * global.mouse_sensitivity * 0.1
		rotation_degrees.y += mouse_look.x
		camera.rotation_degrees.x += mouse_look.y
		# godot bugs visuals when rotation.x is 90 degres
		camera.rotation_degrees.x = clampf(camera.rotation_degrees.x, -89.9, 89.9)

func do_block():
	if magic > 0 and block_buffer > 0 and action_delay <= 0 and not block_active and not block_input:
		viewmodel_play_animation("hold_on")
		block_active = true
		block_input = true

	if not Input.is_action_pressed("action_block"):
		block_input = false
	
	parry_active = on_parry_frametime() and block_active
	
	if (block_active and magic <= 0) or (block_active and not block_input and not on_parry_frametime()):
		if not did_parry:
			viewmodel_animation.stop()
			viewmodel_play_animation("hold_off")
			action_delay = 30

		block_amount = 0
		block_time = 0
		did_parry = false
		block_active = false
		block_input = false
		block_buffer = 0

	if block_active:
		block_time += 1
	
	if parrycombo_time > 0:
		parrycombo_time -= 1
	else:
		parrycombo_time = 0
		parrycombo_amount = 0

	if magic > 0:
		if block_input and not on_parry_frametime():
			magic -= 6
		elif magic > magic_max:
			magic -= 1

func do_block_damage(attack: Attack, attack_result: AttackResult):
	var diff = global_position - attack.knockback_position
	var angle_from_attack = atan2(diff.x, diff.z)
	var angle_from_view = rotation.y
	var angle_diff_raw = angle_from_view - angle_from_attack
	var angle_diff = atan2(sin(angle_diff_raw), cos(angle_diff_raw)) / PI

	var on_block_angle: bool = abs(angle_diff) < 0.45
	
	if block_active and on_block_angle:
		if on_parry_frametime():
			# kills attack delay, you can counter attack imediatly
			action_delay = 0

			# punch with the other hand
			punch_should_be_right = false

			# dumb combo mechanic just for funs,
			# probably breaks if you keep going hehe
			parrycombo_time = 240
			parrycombo_amount += 1

			block_time = parry_frametime - 10
			did_parry = true
			
			var parry_audio = audio.play(sfx_parry)
			parry_audio.process_mode = Node.PROCESS_MODE_ALWAYS
			parry_audio.pitch_scale += parrycombo_amount * 0.05

			block_input = false
			
			viewmodel_play_animation("hold_parry")
		else:
			# reset parry combo if you just blocked
			parrycombo_time = 0
			parrycombo_amount = 0
			
			var block_audio = audio.play(sfx_block)
			block_audio.process_mode = Node.PROCESS_MODE_ALWAYS

			# the parry / super block animation was so fun
			# i made it the normal block ( instafun ) :3
			viewmodel_play_animation("hold_block")

		block_amount += 1

		# juicy freeze frame		
		global.freezeframe = 10
			
		if attack.parry_reaction:
			if attack.inflictor != null and global.check(attack.inflictor, "do_block_reaction"):
				attack.inflictor.do_block_reaction(self, did_parry)
		
			elif attack.agressor != null and global.check(attack.agressor, "do_block_reaction"):
				attack.agressor.do_block_reaction(self, did_parry)
		
		attack_result.was_blocked = true
		attack_result.was_parried = on_parry_frametime()
		return attack_result
	else:
		# attack like normal
		attack.ignore_blocking = true
		return health.do_damage(attack)

func do_punch():
	hud_crosshair.rotation_degrees = 0
	
	var hitscan_results = combat.hitscan(self, global_position, view_direction(), 4, true, false)
	var enemies_position_average := Vector3.ZERO
	var enemies_hit := 0
	var did_hit_world = false

	if punch_buffer > 0 and action_delay <= 0 and not block_active:
		if punch_should_be_right:
			viewmodel_play_animation("punch_right")
		else:
			viewmodel_play_animation("punch_left")

		punch_should_be_right = not punch_should_be_right
		
		punch_animation = punch_animation_start
		action_delay = punch_animation_start
		punch_buffer = 0

	# TODO: punch animation
	var is_punching = punch_animation == punch_animation_hit

	for result in hitscan_results:
		var collider = result.collider

		if combat.object_is_hitbox(collider):
			var victim = collider.parent
			
			if is_punching:
				if global.check(victim, "health"):
					var attack = Attack.new()
					attack.agressor = self
					attack.inflictor = null
					attack.damage = 1
					attack.knockback_power = 5
					attack.knockback_position = position
					attack.is_silent = true
					var attack_result = global.damage(victim, attack)
					if attack_result.did_kill:
						var add_value = victim.health.max_health * hp_steal_mult
						magic = min(magic + (add_value * 600), magic_max)
						health.health = min(health.health + add_value, health.max_health)
				else:
					global.kill(victim, self)
				
			enemies_position_average += victim.global_position
			enemies_hit += 1
		else:
			did_hit_world = true
			# TODO: get more info

	enemies_position_average /= enemies_hit

	if is_punching:
		if enemies_hit > 0:
			global.audio_play_at(sfx_attack, enemies_position_average)
		
		elif did_hit_world:
			# TODO: world hit effect
			pass
		
	if enemies_hit > 0:
		hud_crosshair.rotation_degrees = 45

	if punch_animation > 0:
		punch_animation -= 1

	if action_delay > 0:
		action_delay -= 1

func do_die(killer = null):
	viewmodel_play_animation("die")
	audio.play(sfx_death)
	if killer != null:
		target = killer

func do_move():
	# jump
	if Input.is_action_just_pressed("move_jump"):
		jump_buffer_time = jump_buffer_base
	
	if physics.is_on_ground():
		jump_cayote_time = jump_cayote_base
	
	if jump_buffer_time and jump_cayote_time:
		audio.play(sfx_jump)
		velocity.y = jump_power
		jump_cayote_time = 0
		jump_buffer_time = 0

	# horizotal movement
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	velocity.x += direction.x * speed
	velocity.z += direction.z * speed

	if jump_cayote_time:
		jump_cayote_time -= 1

	if jump_buffer_time:
		jump_buffer_time -= 1

func _physics_process(delta: float) -> void:
	if not health.dead:
		do_punch()
		do_block()
		do_move()

	physics.common_physics(delta)

	# stair smoothing
	view_step_offset = lerp( view_step_offset, 0.0, delta * 20 )
	camera.position.y = max(view_height + view_step_offset, -1)
	
	# death animation
	if health.dead:
		if view_height > 0.25:
			view_height = max(view_height - (delta * 1.5), 0.25)

		if target != null:
			var look_rotation: Vector3 = global.look_at_return(self, target.global_position)
			camera.rotation.x = lerp_angle(camera.rotation.x, look_rotation.x, delta * 8)
			rotation.y = lerp_angle(rotation.y, look_rotation.y, delta * 8)

	# HUD DISPLAY
	hud_health.text = str(int(health.health / health.max_health * 100), "%")
	hud_power.text = str(int(float(magic) / float(magic_max) * 100), "%")
	
	ring_flash(parry_active)

	if health.dead:
		hud_message.text = "[center][color=YELLOW]YOU GOT BEAsTED![/color] \nPRESS [color=RED]\"LEFT CLICK\"[/color] or [color=RED]\"F5\"[/color] to retry![/center]"
		if Input.is_action_just_pressed("action_punch"):
			global.reload_stage()

	# TIMERS
	if block_buffer > 0:
		block_buffer -= 1

	if punch_buffer > 0:
		punch_buffer -= 1

	viewmodel_move_to_camera()

	#if parry_active:
	#	hud_debug_block.text = "SUPERBLOCK"
	#elif block_active:
	#	hud_debug_block.text = "Blocking"
	#else:
	#	hud_debug_block.text = ""

	#hud_debug_action.text = str(action_delay)


func ring_flash(way: bool):
	bracelet_material.set('shader_parameter/mix_amount', 1.0 if way else 0.0)

	# bracelet_material.emission_energy_multiplier = 1.0 if way else 0.0
	return
	# bracelet_material.emission_enabled = way
	# bracelet_material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX if way else BaseMaterial3D.SHADING_MODE_UNSHADED
