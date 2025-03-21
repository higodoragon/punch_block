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
	# decapitated head
	var head_inst := phys_sprite_scene.instantiate() as PhysSprite
	head_inst.assoc = get_correct_assoc(enemy)
	head_inst.killer_vector = killer.global_position
	global.stage.add_child(head_inst)
	head_inst._sprite.region_enabled = true
	head_inst.global_position = enemy.global_position
	head_inst.setup()

	# gore gibs; meat
	var gore_amount_min = 0
	var gore_amount_max := 3 if enemy is not EnemyBrute else 9
	var rand_gore_amount = randi_range(gore_amount_min, gore_amount_max)
	if rand_gore_amount != 0:
		for _i in rand_gore_amount + 1:
			var gore_inst := phys_sprite_scene.instantiate() as PhysSprite
			global.stage.add_child(gore_inst)
			gore_inst.global_position = enemy.global_position
			gore_inst.global_position.y += 0.5
			gore_inst._sprite.texture = gore_texture
			gore_inst._sprite.region_enabled = false
			gore_inst._sprite.hframes = GORE_FRAMES
			gore_inst._sprite.frame = randi_range(0, GORE_FRAMES - 1)
			gore_inst.setup()

	# blood explosion
	var explode_inst := particles_blood_explosion.instantiate() as GPUParticles3D
	global.stage.add_child(explode_inst)
	explode_inst.global_position = enemy.global_position
	explode_inst.global_position.y += 0.5
	explode_inst.emitting = true