extends Node3D

@onready var time_label = $CanvasLayer/TimeLabel
@onready var kills_label = $CanvasLayer/KillsLabel
@onready var title_label = $CanvasLayer/TitleLabel
@onready var next_label = $CanvasLayer/NextLabel
@onready var camera = $Camera3D

var level : Level

func _ready() -> void:
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
	
	title_label.text = str( global.current_level.title, " COMPLETED" )
	time_label.text = str( "TIME: ", draw_mins, ":", draw_secs, ".", draw_msecs )
	kills_label.text = str( "KILLS: ", global.enemy_count_killed, " / ", global.enemy_count )

func _physics_process(delta: float) -> void:
	camera.global_rotation.y += 0.02 * delta
	if Input.is_action_just_pressed("action_punch"):
		queue_free()
		global.load_next_level()
