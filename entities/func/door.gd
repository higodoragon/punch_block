extends Node3D

var is_opened : bool = false
var is_active : bool = false

var base_move_time : float = 4
var base_move_speed : float = 1
var base_wait_time : int = 60 * 4

var move_time : int = 0
var wait_time : int = 0

func _physics_process( delta: float ):
	if not is_active and not is_opened:
		if global.player != null and global_position.distance_to( global.player.global_position ) < 5:
			is_opened = true
			is_active = true
			move_time = base_move_time
			wait_time = base_wait_time

	elif is_active and is_opened and move_time > 0:
		global_position.y += base_move_speed

	elif is_active and is_opened and wait_time > 0:
		pass

	elif is_active and is_opened:
		move_time = base_move_time
		is_opened = false
	
	elif is_active and not is_opened and move_time > 0:
		global_position.y -= base_move_speed
	
	elif is_active and not is_opened:
		is_opened = false
		is_active = false
	
	if move_time > 0:
		move_time -= 1

	if wait_time > 0:
		wait_time -= 1
