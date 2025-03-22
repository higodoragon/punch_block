extends RigidBody3D
class_name PhysSprite

@onready var _sprite: Sprite3D = $Sprite3D
@onready var _despawn_timer: Timer = $Timer
var assoc: GibSpriteAssoc
var despawn_tween: Tween
#var killer_vector: Vector3
var velocity: Vector3
var move_away_from_force: float = 10.0
const FADE_TIME := 2.0
var _bounces := 1

#func setup():
#	#body_entered.connect(_on_body_entered)
#	_despawn_timer.timeout.connect(_despawn)
#
#	# for heads
#	if assoc:
#		_sprite.texture = assoc.texture
#		# _sprite.position.y -= assoc.y_adjustment
#		_sprite.region_rect = assoc.head_rect
#		global_position.y += assoc.y_adjustment
#		#var force = (global_position - killer_vector).normalized() * move_away_from_force
#		#apply_central_impulse(force)
#		apply_central_impulse( Vector3( randf_range( -4, 4 ), randf_range( 10, 15 ), randf_range( -4, 4 ) ) )
#	# for giblets
#	else:
#		apply_central_impulse( Vector3( randf_range( -4, 4 ), randf_range( 2, 5 ), randf_range( -4, 4 ) ) )
#		#apply_central_impulse((Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5)) * 20.0)
#
#		#var rand = randf_range(0.1, 10.0)
#		#apply_torque( Vector3( rand / 2, rand / 2, rand / 2 ) )		
#		_despawn_timer.start(4.0)

func _despawn():
	despawn_tween = get_tree().create_tween()
	# despawn_tween.tween_property(_sprite, 'scale', Vector3.ZERO, FADE_TIME)
	despawn_tween.tween_property(_sprite, 'modulate', Color.TRANSPARENT, FADE_TIME)
	despawn_tween.tween_callback(queue_free)
	

func _on_body_entered(_body):
	if _bounces > 0:
		_bounces -= 1
		$ParticlesBloodExplosion.emitting = true
	else:
		set_deferred('contact_monitor', false)

# func _process(_delta):
# 	var cam := get_viewport().get_camera_3d()
# 	var look_pos := cam.global_position

# 	_sprite.look_at(look_pos, cam.global_transform.basis.y)
# 	_sprite.rotate_object_local(Vector3.FORWARD, 1.2)
