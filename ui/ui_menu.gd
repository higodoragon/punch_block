extends Control
class_name UiMenu

@onready var btn_resume: Button = %ButtonResume
@onready var slider_sens: UiSettingSlider = %SliderSens
@onready var slider_vol: UiSettingSlider = %SliderVol
var _dirty = false

func _ready():
	visible = false

	global.paused.connect(_pause_toggled)
	# mouse sens
	slider_sens.value_changed.connect(_set_mouse_sens)
	slider_sens.slider.value = global.mouse_sensitivity
	# master volume
	slider_vol.value_changed.connect(_set_volume.bind(Settings.bus_master_idx))
	slider_vol.slider.value = db_to_linear(AudioServer.get_bus_volume_db(Settings.bus_master_idx))


func _pause_toggled(way: bool):
	visible = way
	if _dirty:
		_if_dirty()


func _set_volume(val: float, bus: int):
	AudioServer.set_bus_volume_db(bus, linear_to_db(val))
	_dirty = true


func _set_mouse_sens(val: float):
	global.mouse_sensitivity = val
	_dirty = true


func _if_dirty():
	Settings.save_cfg()
	_dirty = false