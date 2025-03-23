extends Control

@export var player: Player
@onready var sprite: Sprite2D = %Sprite2D
@onready var _death_frame := sprite.hframes - 1
@onready var _alive_frames := sprite.hframes - 2
@onready var _slice_size: float


func _ready():
	await player.ready
	player.health.health_updated.connect(update_portrait)
	_slice_size = player.health.max_health / _alive_frames


func update_portrait(current_hp: float):
	var frame = round((_alive_frames - current_hp / _slice_size) + .5 )
	
	if player.health.health >= player.health.max_health:
		frame = 0
	
	if player.health.dead:
		frame = _death_frame
	
	sprite.frame = frame
