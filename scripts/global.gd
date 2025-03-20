extends Node

@onready var audio : AudioManagerComponent = $AudioManagerComponent
@onready var stage_container : Node3D = $StageContainer

var stage : Node3D
var stage_path : String
var stage_textures := "res://func_godot/gamedir/textures/"
var stage_external := ""

var player : CharacterBase
var player_position : Vector3 = Vector3.ZERO
var player_rotation : Vector3 = Vector3.ZERO
var mouse_mode : int = Input.MOUSE_MODE_CAPTURED
@export var mouse_sensitivity: float = 3


var player_active : bool = false
var pause_active : bool = false:
	set(val):
		pause_active = val
		paused.emit(val)
var focus_try : bool = false
var focus_failed : bool = false

var cheats : bool = false

var freezeframe : int = 0

var enemy_list : Array = []

signal paused(way: bool)

#
# preload sounds
const sfx_generic_hurt              = preload( "res://audio/generic_hurt.tres" )
const sfx_generic_pickup            = preload( "res://audio/generic_pickup.tres" )
#const sfx_generic_footsteps         = preload( "res://audio/generic_footsteps.tres" )
const sfx_player_jump               = preload( "res://audio/player_jumping.tres" )
const sfx_player_parry              = preload( "res://audio/player_parry.tres" )
const sfx_player_block              = preload( "res://audio/player_block.tres" )
const sfx_player_footsteps_concrete = preload( "res://audio/player_footsteps_concrete.tres" )
const sfx_sniper_beep               = preload( "res://audio/sniper_attack_beep.tres" )

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	stage_container.process_mode = Node.PROCESS_MODE_PAUSABLE
	process_cmdargs()
	console_defs()
	MaterialReferences.compile_material_references()

func _process( _delta: float ) -> void:
	pause_process()

	# HUD DISPLAY
	if player != null:
		player.hud.visible = not pause_active
		player.viewmodel_move_to_camera()

func _physics_process(delta: float) -> void:
	if freezeframe > 0:
		freezeframe -= 1

func _input( event: InputEvent ):
	if focus_failed and event is InputEventMouseButton and event.button_index == 1:
		focus_try = true
	
	console_is_visible_old = console_is_visible
	console_is_visible = Console.is_visible()
	
	if console_is_visible != console_is_visible_old:
		mouse_update()

	if pause_pressed() and not console_is_visible:
		pause_active = not pause_active
		mouse_update()
	
	if Input.is_action_just_pressed( "debug_togglefullscreen" ):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode( DisplayServer.WINDOW_MODE_FULLSCREEN )
		else:
			DisplayServer.window_set_mode( DisplayServer.WINDOW_MODE_WINDOWED )
		return

	if Input.is_action_just_pressed( "debug_reloadstage" ):
		reload_stage()
		return

func console_defs():
	Console.add_command("map", console_map, ["map name"] )
	Console.add_command("reload", reload_stage )
	
func console_map( map_name : String ):
	if map_name == "list":
		console_map_list()
		return
	
	var map_file := "res://func_godot/maps/%s.map" % map_name
	if ResourceLoader.exists( map_file ):
		Console.print_line("changing to map file \"%s\"" % map_file )
		load_stage( map_file )
	else:
		Console.print_line("map file \"%s\" doesn't exist!" % map_file )

func console_map_list():
	const map_dir_path = "res://func_godot/maps"
	var map_dir := DirAccess.open( map_dir_path )
	if map_dir != null:
		Console.print_line( "showing map list from: \"%s\"" % map_dir_path )
		
		map_dir.list_dir_begin()
		for file: String in map_dir.get_files():
			if not str( file ).ends_with(".map"):
				continue
			Console.print_line( " - %s" % file )

	else:
		Console.print_line( "coudn't open map directiory \"%s\"" % map_dir_path )
	pass

func process_cmdargs():
	var raw_args = OS.get_cmdline_user_args()
	if raw_args.is_empty():
		print( "no arguments passed!" )
		return

	for cmdline_arg in raw_args:
		print( cmdline_arg )

		if cmdline_arg == "cheats":
			cheats = true
			continue
			
		var arg_array = cmdline_arg.split("::")
		if arg_array.size() != 2:
			continue

		if cmdline_arg.begins_with( "map::" ):
			print("start map from: ", arg_array[1] )
			stage_external = arg_array[1]
			continue
				
		if cmdline_arg.begins_with("map-textures::"):
			print("textures are being sourced from: ", arg_array[1] )
			stage_textures = arg_array[1]
			continue

#
# stage loading

func load_stage( path : StringName ):
	stage_path = path
	_load_stage_real.call_deferred()

func reload_stage():
	if not stage_path.is_empty():
		_load_stage_real.call_deferred()

func _load_stage_real():
	# load new level
	if stage != null:
		stage.free()
	
	enemy_list.clear()
	
	stage = FuncGodotMap.new()
	stage.global_map_file = stage_path
	stage.map_settings = preload("res://func_godot/funcgodot_map_settings.tres")
	stage.map_settings.base_texture_dir = stage_textures
	print( stage.map_settings.base_texture_dir )
	stage.verify_and_build()
	
	stage_container.add_child( stage )
	
	# keep random behavior consistent between levels, restarts and such
	seed( "A_COOL_SEED".hash() )

	# add environment
	var world_environment := WorldEnvironment.new()
	world_environment.environment = preload( "res://default_environment.tres" )
	stage.add_child( world_environment )
	
	# add player
	player = preload( "res://entities/info/player.tscn" ).instantiate()
	stage.add_child( player )
	player.global_position = player_position
	player.global_rotation = player_rotation
#
# pause / focus recover stuff

func mouse_update():
	set_mouse_mode( get_mouse_sugested_state() )

func get_mouse_sugested_state() -> int:
	if Console.is_visible():
		return Input.MOUSE_MODE_VISIBLE

	if pause_active:
		return Input.MOUSE_MODE_VISIBLE

	if player != null:
		return Input.MOUSE_MODE_CAPTURED

	return Input.MOUSE_MODE_VISIBLE

func pause_pressed():
	return Input.is_action_just_pressed( "ui_mainmenu" ) or ( OS.get_name() != "Web" and Input.is_action_just_pressed( "ui_cancel" ) )

var console_is_visible_old := false
var console_is_visible := false
			
func pause_process():
	focus_failed = Input.mouse_mode != mouse_mode

	if focus_failed:
		print( "FOCUS FAILED" )

	if focus_try:
		if focus_failed:
			mouse_update()
		else:
			focus_try = false

	if focus_failed or pause_active or Console.is_visible() or freezeframe > 0:
		get_tree().paused = true
	else:
		get_tree().paused = false

#
# random useful funcs

func check( parent : Node, component_name : String ):
	return ( component_name in parent and component_name != null )

func set_mouse_mode( mode : int ):
	Input.set_mouse_mode( mode )
	mouse_mode = mode

func kill( victim : Node, killer : Node = null ):
	if check( victim, "health" ):
		victim.health.dead = true
	
	if check( victim, "do_die" ):
		victim.do_die( killer )
	else:
		victim.queue_free()

func rotation_to_direction( global_rotation : Vector3 ) -> Vector3:
	var direction : Vector3 = Vector3.ZERO
	direction.x = -sin( global_rotation.y ) * cos( global_rotation.x )	
	direction.y = sin( global_rotation.x )
	direction.z = -cos( global_rotation.y ) * cos( global_rotation.x )
	return direction

func angle_to_direction( angle : float ) -> Vector3:
	return rotation_to_direction( Vector3( 0, angle, 0 ) )

func look_at_return( node : Node3D, position : Vector3 ) -> Vector3:
	var old_rotation := node.rotation
	node.look_at( position )
	var look_at_target := node.rotation
	node.rotation = old_rotation
	return look_at_target

func audio_play_at( sfx : AudioSettings, global_position : Vector3 ):
	var audio_player = audio.play( sfx )
	audio_player.global_position = global_position
	return audio_player
