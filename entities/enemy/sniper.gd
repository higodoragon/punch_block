extends CharacterBase

@onready var health: HealthComponent = $HealthComponent
@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var sprite: Sprite3D = $Sprite3D
@onready var physics: CommonPhysicsComponent = $CommonPhysicsComponent
@onready var ai: AIComponent = $AIComponent
@onready var state: StateMachineComponent = $StateMachineComponent

@export_group('Sniper-Specific Settings')
@export var damage: float = 10.0
@export var knockback: float = 100.0
@export var backup_distance: float = 12.0

const STATE_PAIN := [
	{'delay': 10, 'frame': 6}
]


# func _ready():
# 	ai.start_ai()


func _physics_process(delta):
	physics.common_physics(delta)


# =====
