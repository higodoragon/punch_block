extends Node3D

var is_opening : bool = false
var is_active : bool = false

var is_opening_old : bool = false
var is_active_old : bool = false

var base_move_vector : Vector3
var base_move_speed : float
var base_wait_time : int

var initial_position : Vector3
var target_position : Vector3
var move_amount : float = 0
var wait_time : int = 0
var open_once : bool = false
var open_once_lock : bool = false

var targetname : String
var activate_targetname : String

func _func_godot_apply_properties( properties : Dictionary ):
	if not global.on_escape_check( properties ):
		queue_free()
		return

	if not properties.targetname.is_empty():
		global.targetname_add( properties.targetname, self )
		targetname = properties.targetname
	
	if not properties.target.is_empty():
		activate_targetname = properties.target
	
	base_move_vector = properties.movepos
	base_move_speed = properties.speed
	base_wait_time = properties.wait * 60

func _ready():
	initial_position = global_position
	target_position = global_position + base_move_vector
	
	if base_wait_time < 0:
		open_once = true

func _physics_process( delta: float ):

	is_opening_old = is_opening
	is_active_old = is_active
	
	if targetname.is_empty() and global.player != null:
		var flat_player_pos = global.player.global_position * Vector3( 1, 0, 1 )
		var flat_door_pos = global_position * Vector3( 1, 0, 1 )
		var distance = flat_door_pos.distance_to( flat_player_pos )
		if distance < 5:
			door_open()
	
	if is_active and not open_once_lock:
		
		if open_once:

			if is_opening and move_amount < 1:
				move_amount = min( move_amount + base_move_speed, 1 )
			else:
				door_stop()
				open_once_lock = true
		else:
			
			if is_opening and move_amount < 1:
				move_amount = min( move_amount + base_move_speed, 1 )

			elif is_opening and wait_time > 0:
					wait_time -= 1

			elif is_opening:
					door_close()

			elif not is_opening and move_amount > 0:
				move_amount = max( move_amount - base_move_speed, 0 )
			
			else:
				door_stop()
		
		door_update()


func door_update():
	global_position = lerp( initial_position, target_position, move_amount )

func door_open():
	is_opening = true
	is_active = true
	wait_time = base_wait_time

func door_close():
	is_active = true
	is_opening = false

func door_stop():
	is_active = false
	is_opening = false

func do_target_activate( activator : Node3D ):
	open_once = true
	door_open()
