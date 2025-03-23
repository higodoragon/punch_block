extends Node3D

@onready var stats = $CanvasLayer/Stats
@onready var time_label = $CanvasLayer/Stats/TimeLabel
@onready var kills_label = $CanvasLayer/Stats/KillsLabel
@onready var title_label = $CanvasLayer/Stats/TitleLabel
@onready var next_label = $CanvasLayer/Stats/NextLabel
@onready var camera = $Camera3D
@onready var ending = $CanvasLayer/Ending
@onready var ending_g = $CanvasLayer/Ending/Gradiant
@onready var ending_t = $CanvasLayer/Ending/Text
var level : Level
var is_last_level : bool = false

var finale_state : int = 0

func _ready() -> void:
	ending.visible = false
	stats.visible = true
	finale_state = 0

	var msecs : int = global.stage_time % 60
	var secs : int = floor( global.stage_time / 60 ) % 60
	var mins : int = floor( ( global.stage_time / 60 ) / 60 )

	var draw_msecs := str( msecs )
	if msecs < 10:
		draw_msecs = "0" + draw_msecs

	var draw_secs := str( secs )
	if secs < 10:
		draw_secs = "0" + draw_secs

	var draw_mins := str( mins )
	#if mins < 10:
	#	draw_mins = "0" + draw_mins

	var level_name : String = "probably_a_debug_map!"
	if global.current_level:
		level_name = global.current_level.title

	title_label.text = str( level_name, " COMPLETED" )
	time_label.text = str( draw_mins, ":", draw_secs, ".", draw_msecs )
	kills_label.text = str( global.enemy_count_killed, " / ", global.enemy_count )
	var current_level_index : int = global.get_level_index()
	if current_level_index + 1 < global.level_order.size():
		next_label.text = "PRESS [color=RED]LEFT CLICK[/color] FOR MORE GIBBING!"
	else:
		next_label.text = "PRESS [color=RED]LEFT CLICK[/color] TO END THE GIBBING!"
		is_last_level = true

func _physics_process(delta: float) -> void:
	camera.global_rotation.y += 0.02 * delta
	if Input.is_action_just_pressed("action_punch"):
		finale_state += 1
	
	if not is_last_level and finale_state == 1:
		queue_free()
		global.load_next_level()
		return
	
	elif is_last_level and finale_state == 1:
		ending.visible = true
		stats.visible = false

	elif is_last_level and finale_state == 2:
		ending_g.visible = false
		ending_t.visible = false

	elif is_last_level and finale_state == 3:
		queue_free()
		global.load_next_level()
		return
