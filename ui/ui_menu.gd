extends Control
class_name UiMenu

@onready var btn_resume: Button = %ButtonResume
@onready var settings_container: UiSettingsContainer = %SettingsContainer
# @onready var slider_sens: UiSettingSlider = set
# @onready var slider_vol: UiSettingSlider = %SettingsContainer/SliderVol
var _dirty = false

func _ready():
	visible = global.pause_active

	global.paused.connect(_pause_toggled)
	# mouse sens
	settings_container.slider_sens.value_changed.connect(_set_mouse_sens)
	settings_container.slider_sens.slider.value = global.mouse_sensitivity

	# master volume
	settings_container.slider_vol_master.value_changed.connect(_set_volume.bind(Settings.bus_master_idx))
	settings_container.slider_vol_master.slider.value = db_to_linear(AudioServer.get_bus_volume_db(Settings.bus_master_idx))
	# effects volume
	settings_container.slider_vol_effects.value_changed.connect(_set_volume.bind(Settings.bus_effects_idx))
	settings_container.slider_vol_effects.slider.value = db_to_linear(AudioServer.get_bus_volume_db(Settings.bus_effects_idx))
	# music volume
	settings_container.slider_vol_music.value_changed.connect(_set_volume.bind(Settings.bus_music_idx))
	settings_container.slider_vol_music.slider.value = db_to_linear(AudioServer.get_bus_volume_db(Settings.bus_music_idx))
	# resume button
	btn_resume.pressed.connect(_on_resumed)


func _pause_toggled(way: bool):
	visible = way
	if _dirty:
		_if_dirty()


func _set_volume(val: float, bus: int):
	var conv = linear_to_db(val)
	printt(val, conv)
	AudioServer.set_bus_volume_db(bus, linear_to_db(val))
	_dirty = true


func _set_mouse_sens(val: float):
	global.mouse_sensitivity = val
	_dirty = true


func _if_dirty():
	Settings.save_cfg()
	_dirty = false


func _on_resumed():
	global.pause_active = false
	global.mouse_update()
