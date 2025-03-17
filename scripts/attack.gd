class_name Attack

enum INFIGHT_GROUP
{
	NONE,
	GOON,
	QUILIN,
}

enum BLOCKABLE_TYPE
{
	NONE,
	HYPER_DAMAGE,
	# 4 times damage
	THUNDER_BLAST,
	# explosion on punch, doesnt deal self damage
	SNIPE_POINT,
	# single shot hitscan though the level
	CYSTAL_BURST,
	# shoots a long burst of tiny projectiles, 
	FIRE_ROCKET,
	# shoots a exploding projectile, like quake's RL
	TELE_KICK,
	# teleports player to a enemy they aim into,
	# could instakill some enemies
	# the only way to deal damage to the final boss?
}

var damage : int
var knockback_power : float
var knockback_position : Vector3
var agressor : Node3D
var infight_group : INFIGHT_GROUP = INFIGHT_GROUP.NONE
var blockable_type : BLOCKABLE_TYPE = BLOCKABLE_TYPE.NONE
var ignore_blocking : bool = false
var is_parry : bool = false
var is_block : bool = false
var is_silent : bool = false
