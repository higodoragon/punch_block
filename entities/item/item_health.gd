extends Node3D

func do_pickup( toucher : Node3D ):
	if "health" in toucher and toucher.health.health < toucher.health.max_health:
		toucher.health.health = min( toucher.health.health + 25, toucher.health.max_health )
		#if "audio" in toucher:
		#	toucher.audio.play( global.sfx_generic_pickup )
		global.kill( self )
