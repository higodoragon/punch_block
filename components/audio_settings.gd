class_name AudioSettings extends Resource

enum CHANNELS {
	NONE,
	BODY,
	VOICE,
	WEAPON,
}

@export var stream : AudioStream
@export var channel : CHANNELS = CHANNELS.NONE
@export_range( 0, 10 ) var limit : int = 5
@export_range( 0.0, 4.0, .01 ) var volume : float = 1.0
@export_range( 0.0, 4.0, .01 ) var pitch_scale : float = 1.0
@export_range( 0.0, 4.0, .01 ) var pitch_randomness : float = 0.0
