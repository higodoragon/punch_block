@tool

extends BoxContainer
class_name UiSettingSlider

@onready var l_title = $LabelTitle
@onready var l_value = $LabelValue
@onready var slider: Slider = $HSlider

@export var max_val: float = 10.0
@export var title: String = 'PUT SOMETHING HERE'
@export var display: String = '%.4f'

signal value_changed(val: float)


func _ready():
	slider.max_value = max_val
	l_title.text = title
	slider.value_changed.connect(_on_value_changed)
	_on_value_changed(slider.value)


func _on_value_changed(val: float):
	l_value.text = (display % val) if val != 0.0 else 'OFF'
	value_changed.emit(val)