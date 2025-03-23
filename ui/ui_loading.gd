extends Control

@onready var timer: Timer = $Timer
@onready var label: Label = $Label
var dots := 0
const base := 'NOW LOADING. . .'

func _ready():
	visible = false
# 	timer.timeout.connect(_anim)

# func _anim():
# 	var txt = base
# 	for dot in dots:
# 		txt += '.'

# 	label.text = txt
# 	dots = wrapi(dots + 1, 0, 4)