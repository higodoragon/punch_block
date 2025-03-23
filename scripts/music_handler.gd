extends Node
class_name MusicHandler

@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var current_song: MusicInfo

signal music_changed(track: MusicInfo)

func play_music(info: MusicInfo):
	if _audio_stream_player.stream != info.stream:
		_audio_stream_player.stream = info.stream
		_audio_stream_player.play()
		music_changed.emit(info)

func stop_music():
	_audio_stream_player.stop()
