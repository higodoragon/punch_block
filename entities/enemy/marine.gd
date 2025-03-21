extends "res://entities/enemy/sniper.gd"

var state_attack_real_marine := [
	{ sticky_call = "state_attack_active" },
	{ call = "do_attack_real" },
	{ delay = 20, frame = 5 },
	{ goto = state_active },
]

var state_attack_marine := [
	{ sticky_call = "state_attack_active" },
	{ delay = 10, frame = 4 },
	{ call = "do_beep" },
	{ delay = 20, frame = 4 },
	{ call = "do_beep" },
	{ delay = 20, frame = 4 },
	{ call = "do_beep" },
	{ delay = 20, frame = 4 },
	{ goto = state_attack_real_marine },
]

func state_attack_active():
	if ai.target:
		velocity += ai.generic_walk_direction() * speed
		
func _ready():
	state_attack = state_attack_marine
	state_attack_real = state_attack_real_marine
