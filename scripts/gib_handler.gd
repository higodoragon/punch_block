extends Node
class_name GibHandler

@export var gib_assoc_all: GibSpriteAssocAll
@onready var phys_sprite_scene: PackedScene = preload("res://scripts/gibber/phys_sprite.tscn")
@onready var particles_blood_explosion: PackedScene = preload('res://scripts/gibber/particles_blood_explosion.tscn')
@onready var gore_texture: Texture2D = preload("res://assets/gore.png")
const GORE_FRAMES := 6

# func get_correct_head_frame(enemy: CharacterBase):
# 	if enemy.has_node('Sprite3D'):
# 		for assoc in gib_assoc_all.all:
# 			if enemy.sprite.texture == assoc.texture:
# 				return assoc.head_sprite_frame


func get_correct_assoc(enemy: CharacterBase):
	if enemy.has_node('Sprite3D'):
		for assoc in gib_assoc_all.all:
			if enemy.sprite.texture == assoc.texture:
				return assoc


func spawn_gibs(enemy: CharacterBase, killer):
	var killer_pos: Vector3 = killer.global_position if killer else enemy.global_position

	# decapitated head
	var head_inst := phys_sprite_scene.instantiate() as PhysSprite
	head_inst.assoc = get_correct_assoc(enemy)
	#head_inst.killer_vector = killer_pos
	global.stage.add_child(head_inst)
	head_inst._sprite.region_enabled = true
	head_inst.global_position = enemy.global_position + Vector3(0, head_inst.assoc.y_adjustment, 0)

	head_inst.body_entered.connect(head_inst._on_body_entered)
	head_inst._despawn_timer.timeout.connect( head_inst._despawn )

	head_inst._sprite.texture = head_inst.assoc.texture
	head_inst._sprite.region_rect = head_inst.assoc.head_rect
	# head_inst.apply_central_impulse( Vector3( randf_range( -4, 4 ), randf_range( 10, 15 ), randf_range( -4, 4 ) ) )
	head_inst.apply_central_impulse((head_inst.global_position - killer_pos) * 10.0)
	head_inst._despawn_timer.start(4.0)	

	# gore gibs; meat
	var gore_pos = enemy.global_position + Vector3( 0, 1.5, 0 )
	var gore_amount_min = 0
	var gore_amount_max := 3 if enemy is not EnemyBrute else 9
	var rand_gore_amount = randi_range(gore_amount_min, gore_amount_max)
	if rand_gore_amount != 0:
		for _i in rand_gore_amount + 1:
			var gore_inst := phys_sprite_scene.instantiate() as PhysSprite
			global.stage.add_child(gore_inst)
			gore_inst._despawn_timer.timeout.connect(gore_inst._despawn)
			gore_inst.global_position = gore_pos
			gore_inst._sprite.texture = gore_texture
			gore_inst._sprite.region_enabled = false
			gore_inst._sprite.hframes = GORE_FRAMES
			gore_inst._sprite.frame = randi_range(0, GORE_FRAMES - 1)
			gore_inst.apply_central_impulse( Vector3( randf_range( -4, 4 ), randf_range( 2, 5 ), randf_range( -4, 4 ) ) )
			var rand = randf_range(0.1, 10.0)
			gore_inst.apply_torque( Vector3( rand / 2, rand / 2, rand / 2 ) )
			gore_inst._despawn_timer.start(2.0)

	# blood explosion
	var explode_inst := particles_blood_explosion.instantiate() as GPUParticles3D
	global.stage.add_child(explode_inst)
	explode_inst.global_position = gore_pos
	explode_inst.emitting = true
