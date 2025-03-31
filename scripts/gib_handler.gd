extends Node
class_name GibHandler

@export var gib_assoc_all: GibSpriteAssocAll
@onready var phys_sprite_scene: PackedScene = preload("res://scripts/gibber/phys_sprite.tscn")
@onready var blood_explosion_particles: PackedScene = preload('res://scripts/gibber/blood_explosion_particles.tscn')
@onready var blood_explosion_sprite: PackedScene = preload('res://scripts/gibber/blood_explosion_sprite.tscn')
@onready var gore_texture: Texture2D = preload("res://assets/gore.png")
@onready var gore_explosion_texture: Texture2D = preload("res://assets/gore_explosion.png")
const GORE_FRAMES := 6

func get_correct_assoc( enemy: CharacterBase ):
	if enemy.has_node('Sprite3D'):
		for assoc in gib_assoc_all.all:
			if enemy.sprite.texture == assoc.texture:
				return assoc

func spawn_gib_piece( enemy: CharacterBase, killer : CharacterBase, is_head : bool = false ):
	var gib : PhysSprite = phys_sprite_scene.instantiate()
	global.stage.add_child( gib )
	
	var gib_velocity = Vector3.ZERO
	var gib_time = 0
	var killer_direction = Vector3.ZERO
	if killer:
		killer_direction += enemy.global_position.direction_to( killer.global_position ) * Vector3( -1, -1, -1 )
	
	if is_head:
		gib.assoc = get_correct_assoc( enemy )
		gib.global_position = enemy.global_position + Vector3( 0, gib.assoc.y_adjustment, 0 )
		gib._sprite.texture = gib.assoc.texture
		gib._sprite.region_rect = gib.assoc.head_rect
		gib._sprite.region_enabled = true
		
		gib_velocity = killer_direction * 60.0
		gib_velocity.y += randf_range( 20, 40 )
		# particle spawn on bonce
		gib.body_entered.connect( gib._on_body_entered )
		gib_time = 4.0
	else:
		var gib_random_direction : Vector3 = Vector3( randf_range( -1, 1 ), 0, randf_range( -1, 1 ) ).normalized()
		var gib_random_speed : float = randf_range( 2, 32 )
		
		gib.global_position = enemy.global_position + Vector3( 0, 1, 0 )
		gib.gravity_scale = 4
		gib._sprite.texture = gore_texture
		gib._sprite.region_enabled = false
		gib._sprite.hframes = GORE_FRAMES
		gib._sprite.frame = randi_range(0, GORE_FRAMES - 1)
		gib._sprite.scale *= 1.5

		gib.scale *= enemy.scale.y
		if enemy is EnemyBrute:
			gib._sprite.scale *= 1.25
			gib_random_speed *= 1.25

		gib_velocity = gib_random_direction * gib_random_speed
		gib_velocity.y = randf_range( 20, 80 )
		gib_velocity += killer_direction * 10.0
		gib_time = 1.5
			
	gib.scale *= enemy.scale.y

	gib.apply_central_impulse( gib_velocity )
	gib.apply_torque_impulse( Vector3( randf_range( -1.0, 1.0 ), randf_range( -1.0, 1.0 ), randf_range( -1.0, 1.0 ) ) )
	gib._despawn_timer.timeout.connect( gib._despawn )
	gib._despawn_timer.start( gib_time )
			
func spawn_gibs(enemy: CharacterBase, killer):
	# decapitated head
	spawn_gib_piece( enemy, killer, true )

	# gore gibs; meat
	var gore_pos = enemy.global_position + Vector3(0, 1.5, 0)
	var gore_amount = randi_range(3, 4)
	if enemy is EnemyBrute:
		gore_amount += 3

	for _i in gore_amount + 1:
		spawn_gib_piece( enemy, killer, false )
			
	# blood explosion
	var explode_inst : GPUParticles3D = blood_explosion_particles.instantiate()
	global.stage.add_child( explode_inst )
	explode_inst.global_position = gore_pos
	explode_inst.emitting = true
	explode_inst.process_mode = Node.PROCESS_MODE_ALWAYS
	
	var animation_sprite : Sprite3D = blood_explosion_sprite.instantiate()
	global.stage.add_child( animation_sprite )
	animation_sprite.global_position = gore_pos
	animation_sprite.scale *= enemy.scale.y
