@tool

extends BoxContainer
class_name UiSettingSlider

@onready var l_title = $LabelTitle
@onready var l_value = $LabelValue
@onready var slider: Slider = $HSlider

@export var title: String = 'PUT SOMETHING HERE'
@export var display: String = '%.4f'

signal value_changed(val: float)


func _ready():
	l_title.text = title
	slider.value_changed.connect(_on_value_changed)


func _on_value_changed(val: float):
	l_value.text = display % val
	value_changed.emit(val)