extends Control
class_name UiHudBar

# @onready var bar: TextureProgressBar = $TextureProgressBar
@onready var bar: ProgressBar = %ProgressBar
@onready var title_label: Label = %Label
@export var stylebox: StyleBoxFlat
@export var title: String


func setup(input_signal: Signal, value: float, max_value: float):
	input_signal.connect(update)
	title_label.text = title
	bar.value = value
	bar.max_value = max_value
	bar.add_theme_stylebox_override('fill', stylebox)

	# bar.texture_progress.gradient.colors[0] = color
	# bar.texture_progress.height = height
	# bar.texture_progress.width = size.x
	# bar.texture_under.width = size.x


func update(val: float):
	bar.value = val