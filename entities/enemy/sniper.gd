extends CharacterBase
class_name EnemySniper

@onready var health: HealthComponent = $HealthComponent
@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var sprite: Sprite3D = $Sprite3D
@onready var physics: CommonPhysicsComponent = $CommonPhysicsComponent
@onready var ai: AIComponent = $AIComponent
@onready var state: StateMachineComponent = $StateMachineComponent
@onready var parent: Node3D = get_parent()
@onready var laser: Laser = $Laser

@export_group('Sniper-Specific Settings')
@export_range(1, 100) var damage: int = 0
@export var knockback: float = 100.0
@export var backup_distance: float = 12.0
@export var stun_time: float = 40.0
@export var projectile_velocity := 10.0
@export var weapon_range: float = 100.0

var sfx_footstep = global.sfx_generic_footsteps
var last_known_pos: Vector3

# =====
# STATES
# =====

# GENERIC
# -----

var state_pain := [
	{'delay': stun_time, 'frame': 6},
	{'goto': state_active}
]

const state_idle := [
	{'sticky_call': 'do_searth'},
	{'delay': 1, 'frame': 0},
	{'goto': 'state_active'}
]

# mandatory
const state_active := [
	{sticky_call = "do_active"},
	{delay = 15, frame = 1},
	{delay = 15, frame = 2},
	{loop = true}
]

# mandatory
const state_attack := [
	{sticky_call = "do_attack_active"},
	{delay = 20, frame = 3},
	{delay = 1, frame = 4},
	{sticky_call = ""},
	{call = "do_attack"},
	{delay = 20, frame = 5},
	{delay = 1, frame = 4},
	{call = "do_attack"},
	{delay = 20, frame = 5},
	{delay = 1, frame = 4},
	{call = "do_attack"},
	{delay = 20, frame = 5},
	{delay = 1, frame = 4},
	{goto = state_active},
]

# SNIPER SPECIFIC
# -----

## gtfo away from player
const state_flee := [
	{'sticky_call': 'do_flee'},
	
]

## track player
const state_aim := [

]

# =====
# BUILT-INS
# =====

func _ready():
	ai.start_ai()


func _physics_process(delta):
	physics.common_physics(delta)


# =====
#
# =====


func sniper_should_attack():
	if ai.attack_delay <= 0 and global.check(parent, "state_attack"):
		parent.state.set_state(parent.state_attack)
		return true

	if ai.melee_delay <= 0 and ai.in_melee_activation_range() and global.check(parent, "state_melee"):
		parent.state.set_state(parent.state_melee)
		return true
		
	return false


# =====
# STATE ACTIONS
# =====


func do_move():
	if ai.walk_angle_time <= 0:
		ai.walk_angle = ai.target_angle()
		if ai.target_distance() > backup_distance:
			ai.walk_angle += randf_range(-PI * 0.25, PI * 0.25)
		else:
			ai.walk_angle += PI
		ai.walk_angle_time = randi_range(30, 60)
	
	var walk: Vector3 = global.angle_to_direction(ai.walk_angle) * Vector3(1, 0, 1)
	velocity += walk * speed


func do_active():
	if ai.target:
		do_move()
		ai.should_attack()
		# sniper_should_attack()


func do_attack():
	var attack := Attack.new()
	attack.agressor = self
	attack.damage = damage
	attack.knockback_power = knockback
	# combat.fire_projectile(self, global_position, ai.target_direction(), projectile_velocity, attack)
	# for col in res:
	# 	# print('col: %s' % col)
	# 	print('col parent: %s' % col.collider.get_parent())
	combat.hitscan_bullet(self, global_position, ai.target_direction(), attack)
	ai.attack_delay = 100


func do_attack_active():
	if ai.target:
		do_move();


func do_flee():
	do_active()


func do_aim():
	pass


func _process(delta):
	if ai.target:
		update_laser()


func update_laser():
	var res = combat.hitscan(self, global_position, ai.target_direction(), weapon_range, true, true)
	print(res)
	laser.update(res[0].collider.get_parent())