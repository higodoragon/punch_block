extends Node
# class_name Settings

const SETTINGS_CFG_PATH := 'user://settings.cfg'
const SECTION_GENERIC := 'Generic'
const KEY_SENS := 'Mouse Sensitivity'
const KEY_VOL := 'Master Volume'
var _cfg = ConfigFile.new()


@onready var bus_master_idx = AudioServer.get_bus_index('Master')


func _ready():
	load_cfg()


## save the settings CFG file
func save_cfg():
	post('saving cfg')
	# mouse sens
	_cfg.set_value(SECTION_GENERIC, KEY_SENS, global.mouse_sensitivity)
	# master volume in db
	_cfg.set_value(SECTION_GENERIC, KEY_VOL, AudioServer.get_bus_volume_db(bus_master_idx))
	_cfg.save(SETTINGS_CFG_PATH)


## load the settings CFG file
func load_cfg():
	post('loading cfg')
	var error := _cfg.load(SETTINGS_CFG_PATH)
	post('%s' % error)
	if error == ERR_FILE_NOT_FOUND:
		save_cfg()
	if error != OK:
		return

	# mouse sens
	global.mouse_sensitivity = _cfg.get_value(SECTION_GENERIC, KEY_SENS, global.mouse_sensitivity)
	# master volume in db
	AudioServer.set_bus_volume_db(Settings.bus_master_idx, _cfg.get_value(SECTION_GENERIC, KEY_VOL, AudioServer.get_bus_volume_db(bus_master_idx)))


func post(text: String):
	print_rich('[color=RED]%s[/color]' % text)