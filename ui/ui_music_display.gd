extends BoxContainer


@onready var label_now_playing: Label = $LabelNowPlaying


func _ready():
	# hey you, don't question this. it works. shhh.
	# global.music_player is null for some reason
	# and i don't have time to fix that >_>
	for child in global.get_children():
		if child.name == 'MusicHandler':
			child.music_changed.connect(_update)
			break
	

func _update(info: MusicInfo):
	label_now_playing.text = info.title