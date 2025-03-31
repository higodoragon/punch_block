extends RigidBody3D
class_name PhysSprite

@onready var _sprite: Sprite3D = $Sprite3D
@onready var _despawn_timer: Timer = $Timer
var assoc: GibSpriteAssoc
var despawn_tween: Tween
var velocity: Vector3
var move_away_from_force: float = 10.0
const FADE_TIME := 2.0
var _bounces := 1

func _despawn():
	despawn_tween = get_tree().create_tween()
	despawn_tween.tween_property(_sprite, 'scale', Vector3.ZERO, FADE_TIME)
	# despawn_tween.tween_property(_sprite, 'modulate', Color.TRANSPARENT, FADE_TIME)
	despawn_tween.tween_callback(queue_free)

func _on_body_entered(_body):
	if _bounces > 0:
		_bounces -= 1
		$ParticlesBloodExplosion.emitting = true
	else:
		set_deferred('contact_monitor', false)
