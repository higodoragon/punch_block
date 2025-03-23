extends Node3D

@onready var time_label = $CanvasLayer/Control/TimeLabel
@onready var kills_label = $CanvasLayer/Control/KillsLabel
@onready var title_label = $CanvasLayer/Control/TitleLabel
@onready var next_label = $CanvasLayer/Control/NextLabel

var level : Level

func _ready() -> void:
	time_label.text = global.intermission_time
	kills_label.text = global.intermission_kills

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("action_punch"):
		global.set_level( level )
