extends Control

@onready var timer: Timer = $Timer
@onready var label: Label = $Label
@onready var bar: ProgressBar = %ProgressBar
var dots := 0
const base := 'NOW LOADING. . .'


func _ready():
	visible = false
# 	timer.timeout.connect(_anim)


func _on_started_loading():
	print_rich('[color=RED]loading ui: STARTED[/color]')
	visible = true


func _on_finished_loading():
	print_rich('[color=RED]loading ui: FINISHED[/color]')
	visible = false


func _on_progress():
	pass


# func _anim():
# 	var txt = base
# 	for dot in dots:
# 		txt += '.'

# 	label.text = txt
# 	dots = wrapi(dots + 1, 0, 4)