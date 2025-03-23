extends Control

@onready var start_button: Button = %Button
@export var menu: UiMenu
@onready var title_model: Node3D = %Node3D

func _ready():
	start_button.pressed.connect(_on_start_pressed)


func _input(event):
	if event is InputEventKey:
		_on_start_pressed()


func _on_start_pressed():
	print_rich('[color=GREEN]%s[/color]' % 'player pressed start, killing title scene')
	visible = false
	menu.visible = true
	queue_free()


func _process(delta):
	title_model.rotation_degrees.y += 10 * delta