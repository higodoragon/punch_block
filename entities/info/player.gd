class_name Player extends CharacterBase

@onready var health := $HealthComponent
@onready var hitbox := $HitboxComponent
@onready var physics := $CommonPhysicsComponent
@onready var audio := $AudioManagerComponent

@onready var camera := $Camera3D
@onready var collision := $CollisionShape3D
@onready var hud_health : Label = $HUD/Control/HealthText
@onready var hud_block : Label = $HUD/Control/BlockText
@onready var hud_punch : Label = $HUD/Control/PunchText
@onready var hud_crosshair : TextureRect = $HUD/Control/Crosshair

@export var mouse_sensitivity: float = 3
@export var jump_power : float = 10
@export var jump_buffer_base : int = 15
var jump_buffer_time : int = 0
@export var jump_cayote_base : int = 20
var jump_cayote_time : int = 0
var view_step_offset : float = 0
@export var view_step_smooth : float = 20

var target : Node3D
var sfx_footstep = global.sfx_generic_footsteps

func _ready():
	global.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )

func _input( event: InputEvent ) -> void:
	if health.dead:
		return

	if event is InputEventMouseMotion:
		if not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: return
		var mouse_look : Vector2 = -event.relative * mouse_sensitivity * 0.1
		rotation_degrees.y += mouse_look.x
		camera.rotation_degrees.x += mouse_look.y
		# godot bugs visuals when rotation.x is 90 degres
		camera.rotation_degrees.x = clampf( camera.rotation_degrees.x, -89.9, 89.9 )

func _process( delta : float ):
	# stair smoothing
	view_step_offset = lerp( view_step_offset, 0.0, delta * 20 )
	camera.position.y = max( view_height + view_step_offset, -1 ) 
	
	# death animation
	if health.dead:
		if view_height > 0.25:
			view_height = max( view_height - ( delta * 1.5 ), 0.25 )

		if target != null:
			var look_rotation : Vector3 = global.look_at_return( self, target.global_position )
			
			camera.rotation.x = lerp_angle( camera.rotation.x, look_rotation.x, delta * 8 )
			rotation.y = lerp_angle( rotation.y, look_rotation.y, delta * 8 )
	
	hud_health.text = str( health.health )

	if parry_active:
		hud_block.text = "SUPER BLOCK"
	elif block_active:
		hud_block.text = "Blocking"
	else:
		hud_block.text = ""

func view_direction() -> Vector3:
	return global.rotation_to_direction( Vector3( camera.rotation.x, global_rotation.y, 0 ) )


var block_time : int = 0
var block_amount : int = 0 
var block_did_a_parry : bool = false

var block_press_old : bool = false
var block_press : bool = false
var block_active : bool = false
var parry_active : bool = false
var parrycombo_amount : int = 0
var parrycombo_time : int = 0

const parry_frametime = 15

func on_parry_frametime():
	return block_time < parry_frametime

func do_parry( attack : Attack ):
	# PARRY!
	global.freezeframe += 10
	var parry_audio = global.audio_play_at( global.sfx_player_parry, self.global_position )
	parry_audio.pitch_scale += parrycombo_amount * 0.05

	# removes knockback from any attack
	attack.knockback_power = 0

	# kills attack delay, you can counter attack imediatly
	punch_delay = 0
			
	# dumb combo mechanic just for funs,
	# probably breaks if you keep going hehe
	parrycombo_time = 240
	parrycombo_amount += 1

	block_active = false
	block_time = parry_frametime - 10

func do_block():
	block_press_old = block_active
	block_press = Input.is_action_pressed("action_block")

	if ( not block_press_old and block_press ) and punch_delay <= 0 and not block_active and not parry_active:
		block_active = true
		parry_active = true

	if ( block_press_old and not block_press ):
		block_active = false
	
	if not on_parry_frametime():
		parry_active = false
	
	if block_active or parry_active:
		block_time += 1
	else:
		block_time = 0
		block_amount = 0
			
	if parrycombo_time > 0:
		parrycombo_time -= 1
	else:
		parrycombo_time = 0
		parrycombo_amount = 0

func do_block_damage( attack : Attack ):
	var diff = global_position - attack.knockback_position
	var angle_from_attack = atan2( diff.x, diff.z )
	var angle_from_view = rotation.y
	var angle_diff_raw = angle_from_view - angle_from_attack
	var angle_diff = atan2( sin( angle_diff_raw ), cos( angle_diff_raw ) ) / PI
	var on_block_angle : bool = abs( angle_diff ) < 0.5
	var did_a_parry : bool = false

	if on_block_angle and ( block_active or parry_active ):
		if on_parry_frametime():
			did_a_parry = true
			do_parry( attack )
			
		attack.damage = 0
		do_block_steal( attack )
	
	if not did_a_parry:
		# calculate diference
		attack.ignore_blocking = true
		health.do_damage( attack )

	block_amount += 1

func do_block_steal( attack : Attack ):
	pass

const punch_time_delay : int = 0
const punch_time_recovery : int = 20

const punch_animation_start := punch_time_delay + punch_time_recovery
const punch_animation_hit := punch_time_recovery

var punch_buffer := false
var punch_animation : int = 0
var punch_delay : int = 0
var punch_block_delay : int = 0

func do_punch():
	hud_crosshair.rotation_degrees = 0
	hud_punch.text = str( punch_delay )
	
	var hitscan_results = combat.hitscan( self, global_position, view_direction(), 4, true, false )
	var enemies_position_average := Vector3.ZERO
	var enemies_hit := 0
	var did_hit_world = false
	var is_punching = false

	if Input.is_action_just_pressed("action_punch"):
		punch_buffer = true

	if punch_buffer and punch_delay <= 0 and not ( block_active or parry_active ):
		punch_animation = punch_animation_start
		punch_delay = punch_animation_start
		punch_buffer = false

	# TODO: punch animation
	is_punching = punch_animation == punch_animation_hit

	for result in hitscan_results:
		var collider = result.collider

		if combat.object_is_hitbox( collider ):
			var victim = collider.parent
			
			if is_punching:
				var attack = Attack.new()
				attack.agressor = self
				attack.damage = 1
				attack.knockback_power = 5
				attack.knockback_position = position
				attack.is_silent = true
				victim.health.do_damage( attack )
			
			enemies_position_average += victim.global_position
			enemies_hit += 1
			continue
		else:
			did_hit_world = true
			# TODO: get more info
			continue

	enemies_position_average /= enemies_hit

	if is_punching:
		if enemies_hit > 0:
			global.audio_play_at( global.sfx_generic_hurt, enemies_position_average )
		
		elif did_hit_world:
			# TODO: world hit effect
			pass
		
	if enemies_hit > 0:
		hud_crosshair.rotation_degrees = 45

	if punch_animation > 0:
		punch_animation -= 1	

	if punch_delay > 0:
		punch_delay -= 1

func do_die( killer = null ):
	if killer != null:
		target = killer

func do_move():
	# jump
	if Input.is_action_just_pressed("move_jump"):
		jump_buffer_time = jump_buffer_base
	
	if physics.is_on_ground():
		jump_cayote_time = jump_cayote_base
	
	if jump_buffer_time and jump_cayote_time:
		audio.play( global.sfx_player_jump )
		velocity.y = jump_power
		jump_cayote_time = 0
		jump_buffer_time = 0

	# horizotal movement
	var input_dir : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction : Vector3 = ( transform.basis * Vector3( input_dir.x, 0, input_dir.y ) ).normalized()
	
	velocity.x += direction.x * speed
	velocity.z += direction.z * speed

	if jump_cayote_time:
		jump_cayote_time -= 1

	if jump_buffer_time:
		jump_buffer_time -= 1

func _physics_process(delta: float) -> void:
	if health.dead:
		physics.common_physics( delta )
		return

	do_punch()
	do_block()
	do_move()

	physics.common_physics( delta )
