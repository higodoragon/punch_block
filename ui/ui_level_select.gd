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
		inst.button.pressed.connect(load_level.bind(level.map))
		print(level.title)
		print(inst)
		print(level.author)
		inst.label_author.text = 'by %s' % level.author
		inst.label_title.text = '%02d - %s' % [idx + 1, level.title]
		idx += 1


func load_level(mapname: String):
	global.load_stage(mapname)
	global.pause_active = false