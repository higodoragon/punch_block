extends Sprite3D

const frame_per_sec : float = 1.0 / 20.0
var super_frame = 0
var time : float = 0

func _ready() -> void:
	frame = 0
	time = 0

func _process(delta: float) -> void:
	time += delta
	while time > frame_per_sec:
		time -= frame_per_sec

		frame = clamp( super_frame, 0, hframes )

		if super_frame + 1 > hframes:
			queue_free()
			return
		else:
			super_frame += 1

		
		
