extends Node3D
class_name Laser

@onready var beam: MeshInstance3D = $LaserMesh


func update(target: Node3D):
	var cast_point = to_local(target.global_position)
	var mat: StandardMaterial3D = beam.get_active_material(0)
	look_at(target.global_position)
	if target:
		mat.albedo_color = Color.RED
		beam.mesh.height = - cast_point.z
		beam.position.z = cast_point.z / 2
	else:
		mat.albedo_color = Color.WHITE
		beam.mesh.height = target.position.z
		beam.position.z = target.position.z / 2