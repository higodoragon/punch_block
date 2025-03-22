extends Node3D
class_name Projectile

@onready var state : StateMachineComponent = $StateMachineComponent
@onready var audio : AudioManagerComponent = $AudioManagerComponent
@onready var sprite : Sprite3D = $Sprite3D

@export var sfx_impact : AudioSettings

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

var state_hit_parry : Array = [
	{ delay = 4, frame = 1 },
	{ delay = 4, frame = 2 },
	{ delay = 4, frame = 3 },
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
		do_hit()
		return

	position += velocity * delta
	shape_query.transform = global_transform

	var result = get_world_3d().direct_space_state.intersect_shape( shape_query, 1 )
	if result:
		
		var collided = result[0].collider
		if combat.object_is_hitbox( collided ):
			var victim = collided.parent
			
			var is_close_enough = attack.agressor != null and attack.agressor.global_position.distance_to( victim.global_position ) < 4
			if is_close_enough and attack.infight_group == victim.infight_group and victim.infight_group != 0:
				#ignore members of the same species
				return

			do_hit()
			attack.knockback_position = victim.global_position + -self.velocity
			victim.health.do_damage( attack )
		else:
			do_hit()

func do_hit():
	global.audio_play_at( sfx_impact, global_position )
	state.set_state( state_hit )

func do_block_reaction( attacker : Node3D, is_parry : bool ):
	queue_free()
