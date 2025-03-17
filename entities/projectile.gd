extends Node3D
class_name Projectile

@onready var state := $StateMachineComponent
@onready var audio := $AudioManagerComponent

var attack : Attack
var velocity : Vector3
var lifetime : int = 60 * 4
var attack_owner : Node

var state_flying : Array = [
	{ delay = -1, frame = 0 },
]

var state_hit : Array = [
	{ delay = 4, frame = 1 },
	{ delay = 4, frame = 2 },
	{ delay = 4, frame = 3 },
	{ destroy = true },
]

var state_hit_hard : Array = [
	{ delay = 4, frame = 4 },
	{ delay = 4, frame = 5 },
	{ delay = 4, frame = 6 },
	{ destroy = true },
]

var shape_query : PhysicsShapeQueryParameters3D
var shape : SphereShape3D

func _init():
	shape = SphereShape3D.new()
	shape.radius = 0.25
	shape_query = PhysicsShapeQueryParameters3D.new()
	shape_query.shape = shape
	shape_query.collide_with_areas = true
	shape_query.collide_with_bodies = true
	# colide only with hit hitboxes and the world geometry
	shape_query.collision_mask = 17

func _ready():
	var attack_owner_hitbox := attack_owner.find_child("HitboxComponent")
	if attack_owner_hitbox:
			shape_query.exclude = [ attack_owner_hitbox ]
	
	state.current_array = state_flying

func _physics_process( delta: float ) -> void:
	if not state.current_array == state_flying:
		return
	
	if lifetime > 0:
		lifetime -= 1
	else:
		action_hit()
		return

	position += velocity * delta
	shape_query.transform = global_transform

	var result = get_world_3d().direct_space_state.intersect_shape( shape_query, 1 )
	if result:
		var collided = result[0].collider
		if combat.object_is_hitbox( collided ):
			var victim = collided.parent
			attack.knockback_position = victim.global_position + -self.velocity
			victim.health.do_damage( attack )
		
		action_hit()
		return

func action_hit():
		state.set_state( state_hit )
