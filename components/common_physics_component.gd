extends Node
class_name CommonPhysicsComponent

@onready var parent: CharacterBody3D = get_parent()
@onready var collision: CollisionShape3D = parent.find_child("CollisionShape3D")
@onready var step_cast: ShapeCast3D = $StepCast
@onready var step_ray: RayCast3D = $StepRay
@onready var mat_sfx_ray: RayCast3D = $MatSfxRay

@export_group('Material SFX')
@export var fs_concrete: AudioSettings
@export var fs_grass: AudioSettings
@export var fs_gravel: AudioSettings
@export var fs_water: AudioSettings
@export var landing_concrete: AudioSettings
@export var landing_grass: AudioSettings
@export var landing_gravel: AudioSettings
@export var landing_water: AudioSettings

var on_ground_prev: bool = true
var on_ground: bool = true
var on_ground_force: bool = false

var ground_time: int = 0
var air_time: int = 0
var ground_time_old: int = 0
var air_time_old: int = 0

var footstep_amount = 0

enum MATSFX {
	FOOTSTEPS,
	LANDING,
}


func _ready():
	await get_parent().ready
	mat_sfx_ray.reparent(get_parent())


func is_on_ground():
	return on_ground_force or parent.is_on_floor()

func snap_to_stair(delta: float):
	var global_position_pre: Vector3 = parent.global_position
	step_cast.shape = collision.shape
	step_cast.global_position = parent.global_position
	step_cast.global_position.x += parent.velocity.x * delta
	step_cast.global_position.z += parent.velocity.z * delta
	step_cast.global_position.y += parent.step_height_up + (step_cast.shape.height / 2)
	step_cast.target_position.y = - parent.step_height_up + -parent.step_height_down

	if not (on_ground_prev or on_ground):
		return

	# checks
	var query = PhysicsShapeQueryParameters3D.new()
	query.exclude = [parent]
	query.shape = collision.shape
	query.transform = step_cast.global_transform
	var result = global.stage.get_world_3d().direct_space_state.intersect_shape(query, 1)

	step_cast.force_shapecast_update()

	if not step_cast.is_colliding() or parent.velocity.y > 01:
		on_ground_force = false
		return
	else:
		on_ground_force = true

	if result:
		return

	var step_position = step_cast.get_collision_point(0)
	var step_height = step_position.y - parent.global_position.y

	#  gets angle using raycasting ( shapecast has very inacurate normals )
	step_ray.global_position = Vector3(step_position.x, step_position.y + 0.5, step_position.z)
	step_ray.force_raycast_update()
	var step_angle = step_ray.get_collision_normal().angle_to(Vector3.UP)

	# avoids climping slopes too steep
	if step_angle > parent.floor_max_angle:
		return
	
	# avoids snaping to the same floor
	if abs(step_height) < 0.01:
		return

	# known issues:
	# can snap multiple times between frames, snaps on slopes cases slight jitter.
	# i won't fix them, im tired of working on stair climbing :<

	parent.velocity.y = 0
	parent.global_position.y = step_cast.get_collision_point(0).y
	
	if parent is Player:
		parent.view_step_offset -= parent.global_position.y - global_position_pre.y

func common_physics(delta):
	on_ground_prev = on_ground
	on_ground = is_on_ground()

	if on_ground:
		ground_time += 1
	else:
		air_time += 1
	
	if on_ground != on_ground_prev:
		ground_time_old = ground_time
		ground_time = 0
		air_time_old = air_time
		air_time = 0

	#
	# footstep audio

	if global.check(parent, "audio"): # and global.check(parent, "sfx_footstep"):
		if is_on_ground():
			footstep_amount += ((parent.velocity * Vector3(1, 0, 1)) * delta).distance_to(Vector3.ZERO)
		
		if on_ground and not on_ground_prev and air_time_old > 5:
			# landing??
			# parent.audio.play( parent.sfx_footstep )
			play_material_sound(MATSFX.LANDING)
			footstep_amount = 0

		if footstep_amount > parent.footstep_frequency:
			footstep_amount = fmod(footstep_amount, parent.footstep_frequency)
			# parent.audio.play(parent.sfx_footstep)
			play_material_sound(MATSFX.FOOTSTEPS)

	# gravity
	parent.velocity.y += -parent.gravity

	# friction
	parent.velocity.x *= parent.friction
	parent.velocity.z *= parent.friction
	
	snap_to_stair(delta)
	parent.move_and_slide()

	if parent.position.y < -500:
		if parent is Player:
			# ops... sorry about that
			parent.global_position = global.player_position
			parent.global_rotation.y = global.player_rotation.y
			parent.camera.global_rotation.x = global.player_rotation.x
		else:
			global.kill(parent)

## what func_godot generates is:
## a StaticBody3D.
## And a child mesh instance
## which has multiple Surfaces in its Mesh resource
func play_material_sound(foley_type: int):
	mat_sfx_ray.force_raycast_update()
	
	var col = mat_sfx_ray.get_collider()
	
	if col and col is StaticBody3D:
		col = col as StaticBody3D
		printt(col)

		var child_mesh: MeshInstance3D = col.get_child(0) # 0 is always the mesh instance
		var relevant_material: StandardMaterial3D

		# simple
		relevant_material = child_mesh.get_active_material(0)
		
		# complex
		# for surf in child_mesh.mesh.get_surface_count():
		# 	child_mesh.get_active_material(0)
		
		
		var ref = get_ref_from_mat(relevant_material)
		var sound_set = []

		if not ref:
			sound_set = [fs_concrete, landing_concrete]
		else:
			match ref.material_kind:
				ref.MATERIAL_KIND.CONCRETE:
					sound_set = [fs_concrete, landing_concrete]
				ref.MATERIAL_KIND.GRASS:
					sound_set = [fs_grass, landing_grass]
				ref.MATERIAL_KIND.GRAVEL:
					sound_set = [fs_gravel, landing_gravel]
				ref.MATERIAL_KIND.WATER:
					sound_set = [fs_water, landing_water]

		match foley_type:
			MATSFX.FOOTSTEPS:
				parent.audio.play(sound_set[0])
			MATSFX.LANDING:
				parent.audio.play(sound_set[1])


## find the MaterialTextureReference that is linked to the StandardMaterial3D
func get_ref_from_mat(mat: StandardMaterial3D) -> MaterialTextureReference:
	for ref in MaterialReferences.refs:
		if ref.material_file == mat:
			return ref

	return null