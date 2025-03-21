extends Node

@export var player: Player
@export var health: HealthComponent
@export var health_bar: UiHudBar
@export var magic_bar: UiHudBar


func _ready():
	await player.ready

	health_bar.setup(health.health_updated, health.health, health.max_health)
	magic_bar.setup(player.magic_updated, player.magic, player.magic_max)

	queue_free()