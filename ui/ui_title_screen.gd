extends Control

@onready var start_button: Button = %Button
@onready var title_model: Node3D = %Node3D
@onready var title_parent: Node3D = %TitleParent
@export var menu: UiMenu
@export var spin_speed_cam := 5.0
@export var spin_speed_parent := 20.0

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
	title_model.rotation_degrees.y += spin_speed_cam * delta
	title_parent.rotation_degrees.y += spin_speed_parent * delta