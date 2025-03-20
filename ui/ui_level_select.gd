extends Control
class_name UiLevelSelect

@export var levels: Array[Level]
@export var preview_scene: PackedScene
@onready var box: BoxContainer = %Box

func _ready():
	# populate list of levels
	var idx := 0
	for level in levels:
		var inst = preview_scene.instantiate() as UiLevelPreview
		box.add_child(inst)
		print(level.title)
		print(inst)
		inst.label.text = '%02d - %s' % [idx + 1, level.title]
		idx += 1