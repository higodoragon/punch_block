extends Node3D
class_name AudioManagerComponent

func create( audio_player, audio_settings : AudioSettings ):
	var same_amount = 0
	for p in get_children():
		if p.stream == audio_settings.stream:
			same_amount += 1
		if same_amount >= audio_settings.limit:
			p.queue_free()

	audio_player.bus = 'Effects'
	audio_player.stream = audio_settings.stream
	audio_player.volume_db = audio_settings.volume_db
	audio_player.pitch_scale = audio_settings.pitch_scale
	audio_player.pitch_scale += randf_range( -audio_settings.pitch_randomness, audio_settings.pitch_randomness )
	audio_player.finished.connect( audio_player.queue_free )
	audio_player.attenuation_filter_cutoff_hz = 20500

	self.add_child( audio_player )	
	audio_player.play()
	
	return audio_player

func play( sound_settings : AudioSettings ) -> AudioStreamPlayer3D:
	return create( AudioStreamPlayer3D.new(), sound_settings )

func play_interface( sound_settings : AudioSettings ) -> AudioStreamPlayer:
	return create( AudioStreamPlayer.new(), sound_settings )
