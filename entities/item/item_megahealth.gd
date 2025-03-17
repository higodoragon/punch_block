extends Node3D

func do_pickup( toucher : Node3D ):
	if "health" in toucher:
		toucher.health.health += 100
		if "audio" in toucher:
			toucher.audio.play( global.sfx_generic_pickup )
		global.kill( self )
