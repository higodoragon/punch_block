@tool

extends HBoxContainer

@export var line: ResCreditLine
@onready var a: MarkdownLabel = $A
@onready var b: MarkdownLabel = $B

func _ready():
	a.markdown_text = '[color=#c0c0c0]%s[/color]' % line.who
	b.markdown_text = '%s' % line.what