class_name AudioSettings extends Resource

enum CHANNELS {
	NONE,
	BODY,
	VOICE,
	WEAPON,
}

@export var stream : AudioStream
@export var stream_gravel : AudioStream
@export var stream_water : AudioStream
@export var stream_grass : AudioStream
@export var stream_metal : AudioStream
@export var channel : CHANNELS = CHANNELS.NONE
@export var limit : int = 5
@export var volume_db : float = 1.0
@export var pitch_scale : float = 1.0
@export var pitch_randomness : float = 0
