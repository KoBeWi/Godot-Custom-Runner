@tool
extends Node
class_name CustomRunner

## Custom Runner main script. You can customize it by modifying the Config.gd file.

## The shortcut that will trigger the plugin.
var SHORTCUT = KEY_F7

## If true, pressing the shortcut will invoke CustomRunner for that scene.
func _can_play_scene(scene: Node) -> bool:
	return true

## Add variables that will be passed to the game.
## Variable "scene", containing currently opened scene's path, is added automatically.
func _gather_variables(scene: Node):
	pass

## Return the path of the "game" scene of your project (i.e. main gameplay scene).
## If you return empty string, the current scene will play instead.
func _get_game_scene(for_scene: Node) -> String:
	return ""

## Returns true if the game was ran via CustomRunner.
static func is_custom_running() -> bool:
	return not OS.get_environment("__custom_runner_data__").is_empty()

## Retrieves a passed variable's value.
static func get_variable(variable: String):
	assert(is_custom_running(), "Can't retrieve data if not running via plugin.")
	var data: Dictionary = str_to_var(OS.get_environment("__custom_runner_data__"))
	return data[variable]

var plugin: Node
var data: Dictionary
var prev_game_scene: String

func _unhandled_key_input(event: InputEvent):
	if plugin.get_editor_interface().is_playing_scene():
		return
	
	if event is InputEventKey and event.pressed and event.keycode == SHORTCUT:
		if event.shift_pressed:
			if data.is_empty() or prev_game_scene.is_empty():
				push_warning("CustomRunner: Can't do Quick Run before running mormally at least once.")
				return
		else:
			var root: Node = plugin.get_editor_interface().get_edited_scene_root()
			if not _can_play_scene(root):
				push_warning("CustomRunner: Invalid scene to play.")
				return
			
			data.clear()
			add_variable("scene", root.scene_file_path)
			_gather_variables(root)
			
			var game_scene := _get_game_scene(root)
			if game_scene.is_empty():
				game_scene = root.scene_file_path
			
			prev_game_scene = game_scene
		
		OS.set_environment("__custom_runner_data__", var_to_str(data))
		plugin.get_editor_interface().play_custom_scene(prev_game_scene)
		OS.set_environment("__custom_runner_data__", "")
		get_viewport().set_input_as_handled()

## Adds a variable to be passed to the running game. Use in [method _gather_variables].
func add_variable(variable: String, value):
	if value is Object:
		push_error("The value can be non-Object only.")
		return
	
	data[variable] = value
