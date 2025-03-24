extends Node

@onready var audio: AudioManagerComponent = $AudioManagerComponent
@onready var stage_container: Node3D = $StageContainer
@onready var music_handler: MusicHandler = $MusicHandler
@onready var gib_handler: GibHandler = $GibHandler
@onready var focus_warning : Control = $FocusWarning

var intermission: Node3D
var title_menu : Node3D

var stage: Node3D
var stage_path: String
var stage_textures := "res://func_godot/gamedir/textures/"
var stage_external := ""
var stage_time : int = 0

var player: CharacterBase
var player_position: Vector3 = Vector3.ZERO
var player_rotation: Vector3 = Vector3.ZERO

var mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE

var title_first_click : bool = false
var title_initial_delay : int = 60
var focus_failed_time : int = 0

@export var mouse_sensitivity: float = 3
@export var level_order: Array[Level]
@export var button_sfx : AudioSettings
@export var door_sfx : AudioSettings

@export var ambience_city : AudioStream
@export var ambience_factory : AudioStream

var player_active: bool = false
var pause_active: bool = false:
	set(val):
		pause_active = val
		paused.emit(val)

var focus_try: bool = false
var focus_failed: bool = false

var cheats: bool = false

var freezeframe: int = 0

var enemy_list: Array = []
var enemy_count : int = 0
var enemy_count_killed : int = 0

var intermission_time : String
var intermission_kills : String

var current_level : Level = null

@export var intermission_music : MusicInfo
@export var title_music : MusicInfo

signal paused(way: bool)

#
# preload sounds

func _ready():
	Console.console_opened.connect( console_opened )
	Console.console_closed.connect( console_closed )
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	stage_container.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	process_cmdargs()
	console_defs()
	
	MaterialReferences.compile_material_references()

func _process(_delta: float) -> void:
	# HUD DISPLAY
	if player != null:
		player.hud.visible = not pause_active
		player.viewmodel_move_to_camera()

	pause_process()

func _physics_process(delta: float) -> void:
	if freezeframe > 0:
		freezeframe -= 1

	if message_time > 0:
		message_time -= 1

	if player != null and message_time <= 0:
		player.hud_message.text = ""
	
	stage_time += 1

func _input(event: InputEvent):
	if focus_failed and event is InputEventMouseButton and event.button_index == 1:
		focus_try = true

	if Input.is_action_just_pressed("debug_togglefullscreen"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		return

	if Console.is_visible():
		return

	if intermission:
		# intermission disables pauses
		if pause_active != false:
			pause_active = false
			mouse_update()
	elif title_menu:
		# title menu pause behavior
		if ( not pause_active and event.is_pressed() ) or ( pause_active and pause_pressed() ):
			pause_active = not pause_active
			mouse_update()
	else:
		# normal pause behavior
		if pause_pressed():
			pause_active = not pause_active
			mouse_update()
		
	if stage:
		if Input.is_action_just_pressed("debug_reloadstage"):
			reload_stage()
			return

func console_opened():
	mouse_update()

func console_closed():
	mouse_update()

func console_defs():
	Console.add_command("map", console_map, ["map name"])
	Console.add_command("reload", reload_stage)
	Console.add_command("print_targetnames", targetname_print)
	Console.add_command("escape", on_escape_toggle)

func console_map(map_name: String):
	if map_name == "list":
		console_map_list()
		return
	
	var map_file := "res://func_godot/maps/%s.map" % map_name
	if ResourceLoader.exists(map_file):
		Console.print_line("changing to map file \"%s\"" % map_file)
		load_stage(map_file)
	else:
		Console.print_line("map file \"%s\" doesn't exist!" % map_file)

func console_map_list():
	const map_dir_path = "res://func_godot/maps"
	var map_dir := DirAccess.open(map_dir_path)
	if map_dir != null:
		Console.print_line("showing map list from: \"%s\"" % map_dir_path)
		
		map_dir.list_dir_begin()
		for file: String in map_dir.get_files():
			if not str(file).ends_with(".map"):
				continue
			Console.print_line(" - %s" % file)
	else:
		Console.print_line("coudn't open map directiory \"%s\"" % map_dir_path)
	pass

func process_cmdargs():
	var raw_args = OS.get_cmdline_user_args()
	if raw_args.is_empty():
		print("no arguments passed!")
		return

	for cmdline_arg in raw_args:
		print(cmdline_arg)

		if cmdline_arg == "cheats":
			cheats = true
			continue
			
		var arg_array = cmdline_arg.split("::")
		if arg_array.size() != 2:
			continue

		if cmdline_arg.begins_with("map::"):
			print("start map from: ", arg_array[1])
			stage_external = arg_array[1]
			continue
				
		if cmdline_arg.begins_with("map-textures::"):
			print("textures are being sourced from: ", arg_array[1])
			stage_textures = arg_array[1]
			continue

#
# stage loading

var targets: Dictionary

var on_escape = false

func on_escape_check(propeties: Dictionary):
	if propeties.flags & 1 and on_escape:
		return true

	if propeties.flags & 2 and on_escape:
		return false
	
	return true

func on_escape_toggle():
	print("now escaping")
	on_escape = not on_escape

func targetname_print():
	print("printing all targetnames")
	for tn in targets:
		print(tn)

func targetname_add(targetname, node):
	if not targetname in targets:
		targets[targetname] = TargetGroup.new()

	targets[targetname].group.append(node)

func targetname_activate(targetname, activator):
	print(targetname, " is being activated")
	if not targetname in targets:
		print("empty/invalid targetname called")
		return
		
	for node in targets[targetname].group:
		if node == null:
			continue

		if node == activator:
			continue

		if "do_target_activate" in node:
			node.do_target_activate(activator)

func funcgodot_common_defs(node: Node, properties: Dictionary):
	if not global.on_escape_check(properties):
		node.queue_free()
		return

	if not properties.targetname.is_empty():
		global.targetname_add(properties.targetname, node)
		node.targetname = properties.targetname
	
	if not properties.target.is_empty():
		node.activate_targetname = properties.target
	
	if global.check(node, "message"):
		node.message = properties.message

var message_time = 0

func message_player(message: String, time: int = 120):
	print("message to the player: ", message)
	if player:
		player.hud_message.text = str("[center]", message, "[/center]")

	message_time = time

func get_level_from_map( map_path : String ):
	for i in level_order.size():
		var level = level_order[ i ]
		if get_res_from_uid( level.map ) == map_path:
			return level
	
	return null

func get_level_index():
	for i in level_order.size():
		var level = level_order[i]
		if current_level == level:
			return i
	
	return -1

func load_next_level():
	# find level id
	var current_level_index : int = get_level_index()

	if current_level_index + 1 < level_order.size():
		load_level( level_order[ current_level_index + 1 ] )
		return

	if level_order.is_empty():
		push_error( "level order is empty!!!" )
		return

	if current_level_index == -1:
		print( "current map not found in level list!! booting to first level in the list" )
		load_level( level_order[0] )
		return

	print( "you finished the game!!" )
	clear_stage()
	title_open()

func load_level( level: Level ):
	load_stage( level.map )
	pause_active = false
	
func clear_stage():
	_clear_stage_real.call_deferred()

func _clear_stage_real():
	if stage != null:
		stage.free()
	
	enemy_list.clear()
	targets.clear()

func _clear_others_real():
	if title_menu != null:
		title_menu.free()

	if intermission != null:
		intermission.free()

func load_stage(path: StringName):
	stage_path = path
	_load_stage_real.call_deferred()

func reload_stage():
	if not stage_path.is_empty():
		_load_stage_real.call_deferred()

func _load_stage_real():
	_clear_stage_real()
	_clear_others_real()

	# restart stats
	enemy_count = 0
	enemy_count_killed = 0
	stage_time = 0
	
	stage = preload("res://scripts/fgm.tscn").instantiate()
	#printt(stage, stage_container, stage_path)
	if 'uid' in stage_path:
		var id_path = get_res_from_uid(stage_path)
		print('LOADING MAP FROM UID %s' % id_path)
		stage.local_map_file = id_path
	else:
		print('NOT LOADING MAP FROM UID')
		stage.local_map_file = stage_path
	# stage.map_settings = preload("res://func_godot/funcgodot_map_settings.tres")
	stage.map_settings.base_texture_dir = stage_textures
	print(stage.map_settings.base_texture_dir)
	stage.verify_and_build()
	stage_container.add_child(stage)
	
	# keep random behavior consistent between levels, restarts and such
	seed("A_COOL_SEED".hash())

	# add environment
	var world_environment := WorldEnvironment.new()
	world_environment.environment = preload("res://environment_outside.tres")
	stage.add_child(world_environment)
	
	current_level = get_level_from_map( stage.local_map_file )
	print( current_level )
	if current_level != null:
		# play music
		if current_level.music:
			music_handler.play_music( current_level.music )

		# play ambient
		var ambience_player : AudioStreamPlayer = AudioStreamPlayer.new()
		stage.add_child( ambience_player )
		
		if current_level.ambience_id != 0:
			ambience_player.stream = ambience_factory
		else:
			ambience_player.stream = ambience_city
		
		ambience_player.volume_db = -20
		ambience_player.bus = 'Effects'
		ambience_player.process_mode = Node.PROCESS_MODE_ALWAYS
		ambience_player.play()

	# add player
	player = preload("res://entities/info/player.tscn").instantiate()
	stage.add_child( player )
	player.global_position = global.player_position
	player.global_rotation = global.player_rotation
	player.reset_physics_interpolation()
	global.mouse_update()

func boot_to_intermission():
	clear_stage()
	music_handler.play_music( intermission_music )
	intermission = preload("res://intermission/intermission.tscn").instantiate()
	stage_container.add_child( intermission )
	mouse_update()

func title_open():
	clear_stage()
	_clear_others_real()
	
	title_menu = preload("res://ui/ui_title_screen.tscn").instantiate()
	stage_container.add_child( title_menu )
	music_handler.play_music( title_music )
	mouse_update()
#
# pause / focus recover stuff

func mouse_update():
	set_mouse_mode( get_mouse_sugested_state() )

func get_mouse_sugested_state() -> Input.MouseMode:
	if Console.is_visible():
		print("console_visible")
		return Input.MOUSE_MODE_VISIBLE

	if title_menu != null:
		print("title_menu")
		return Input.MOUSE_MODE_VISIBLE

	if intermission != null:
		print("intermission")
		return Input.MOUSE_MODE_VISIBLE

	if pause_active:
		print("paused")
		return Input.MOUSE_MODE_VISIBLE

	if player != null:
		print("controlling character")
		return Input.MOUSE_MODE_CAPTURED

	print("default")
	return Input.MOUSE_MODE_VISIBLE

func pause_pressed():
	return Input.is_action_just_pressed("ui_mainmenu") or ( OS.get_name() != "Web" and Input.is_action_just_pressed("ui_cancel") )

var console_is_visible_old := false
var console_is_visible := false
			
func pause_process():
	focus_failed = Input.mouse_mode != mouse_mode

	if focus_failed:
		focus_failed_time += 1
	else:
		focus_failed_time = 0

	var focus_failed_warning = focus_failed_time > 5

	if OS.get_name() == "Web":
		focus_warning.visible = focus_failed_warning
		if global.player != null:
			global.player.hud.visible = global.player.hud.visible and not focus_failed_warning
		
	if focus_try:
		if focus_failed:
			mouse_update()
		else:
			focus_try = false

	get_tree().paused = ( focus_failed or pause_active or Console.is_visible() or freezeframe > 0 )

#
# random useful funcs

func check(parent: Node, component_name: String):
	return (component_name in parent and component_name != null)

func set_mouse_mode( mode: int ):
	Input.mouse_mode = mode
	mouse_mode = mode

func damage( victim : Node, attack : Attack ) -> AttackResult:
	if global.check( victim, "health" ):
		return victim.health.do_damage( attack )
	else:
		var attack_result = AttackResult.new()
		attack_result.did_kill = true
		global.kill( victim )
		return attack_result

func kill(victim: Node, killer: Node = null):
	if check(victim, "ai"):
		enemy_count_killed += 1
	
	if not check(victim, "do_die") and check(victim, "sfx_death"):
		global.audio_play_at(victim.sfx_death, victim.global_position)
	
	if check(victim, "health"):
		victim.health.dead = true
		if not victim is Player:
			gib_handler.spawn_gibs(victim, killer)

	if check(victim, "activate_targetname") and not victim.activate_targetname.is_empty():
		targetname_activate(victim.activate_targetname, killer)

	if check(victim, "message") and not victim.message.is_empty():
		message_player( victim.message )

	if check(victim, "do_die"):
		victim.do_die(killer)
	else:
		victim.queue_free()

func stun(victim: Node, time: int = -1, is_pain: bool = false):
	if victim == null:
		return
	
	if not global.check(victim, "ai"):
		return
	
	if not global.check(victim, "state"):
		return

	if is_pain and victim.pain_time < 0:
		return

	if not is_pain and victim.stun_time < 0:
		return

	if is_pain:
		victim.state.set_state(victim.state_pain)
	else:
		victim.state.set_state(victim.state_stun)

	if time < 0:
		if is_pain:
			victim.ai.stun_time = victim.pain_time
		else:
			victim.ai.stun_time = victim.stun_time
	else:
		victim.ai.stun_time = time

	victim.ai.stun_active = true
	victim.ai.stun_is_pain = is_pain


func rotation_to_direction(global_rotation: Vector3) -> Vector3:
	var direction: Vector3 = Vector3.ZERO
	direction.x = - sin(global_rotation.y) * cos(global_rotation.x)
	direction.y = sin(global_rotation.x)
	direction.z = - cos(global_rotation.y) * cos(global_rotation.x)
	return direction

func angle_to_direction(angle: float) -> Vector3:
	return rotation_to_direction(Vector3(0, angle, 0))

func look_at_return(node: Node3D, position: Vector3) -> Vector3:
	var old_rotation := node.rotation
	node.look_at(position)
	var look_at_target := node.rotation
	node.rotation = old_rotation
	return look_at_target

func audio_play_at(sfx: AudioSettings, global_position: Vector3):
	var audio_player = audio.play(sfx)
	audio_player.global_position = global_position
	return audio_player

func get_res_from_uid(uid):
	var res_id = ResourceLoader.get_resource_uid(uid)
	var id_path = ResourceUID.get_id_path(res_id)
	return id_path
