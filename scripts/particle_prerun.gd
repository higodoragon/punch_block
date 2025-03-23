extends Node3D

func _ready():
	for child in get_children():
		if child is GPUParticles3D:
			print('prerun: running %s' % child)
			child.emitting = true
			await get_tree().create_timer(1.0).timeout
			child.queue_free()
	queue_free()