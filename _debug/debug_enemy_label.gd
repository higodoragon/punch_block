extends Label3D

@export var enemy: CharacterBase

## janky check to make sure the CharacterBase is an enemy
func check():
	var checks = [
		'Sniper' in enemy.name,
		enemy.has_method('do_move')
	]
	return checks.all(func(a): return a)

func _ready():
	if not enemy.is_node_ready():
		await enemy.ready

	if not check():
		return

	if enemy is EnemySniper:
		enemy.state.state_changed.connect(_on_state_changed)


func _on_state_changed(array: Array, idx: int):
	text = '%s %s' % [idx, array]