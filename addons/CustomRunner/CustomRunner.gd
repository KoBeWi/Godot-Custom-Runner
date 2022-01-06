tool
extends EditorPlugin
class_name CustomRunner

### Modify constants/methods to your needs.

const SHORTCUT = KEY_F7

## If true, pressing the shortcut will invoke CustomRunner for that scene.
func _can_play_scene(scene: Node) -> bool:
	return true

## Add variables that will be passed to game.
## Variable "scene", containing currently opened scene, is added automatically.
func _gather_variables(scene: Node):
	add_variable("mouse_pos", scene.get_local_mouse_position())

## Return the path of the "game" scene of your project (i.e. main gameplay scene).
## If you return empty string, current scene will play instead.
func _get_game_scene(for_scene: Node) -> String:
	return ""

### Configurable part END

## Use these static functions in running game to access the passed variables.

## Returns true if the game was ran via CustomRunner.
static func is_custom_running() -> bool:
	return not OS.get_environment("__run_data__").empty()

## Retrieves passed variable value.
static func get_variable(variable: String):
	var data: Dictionary = str2var(OS.get_environment("__run_data__"))
	if data.empty():
		push_error("Run data not found.")
	else:
		return data[variable]

### Unimportant stuff

var data: Dictionary

func _unhandled_key_input(event: InputEventKey):
	if get_editor_interface().is_playing_scene():
		return
	
	if event.pressed and event.scancode == SHORTCUT:
		var root := get_editor_interface().get_edited_scene_root()
		if not _can_play_scene(root):
			push_warning("Invalid scene to play.")
			return
		
		data.clear()
		add_variable("scene", root.filename)
		_gather_variables(root)
		
		var game_scene := _get_game_scene(root)
		if game_scene.empty():
			game_scene = root.filename
		
		OS.set_environment("__run_data__", var2str(data))
		get_editor_interface().play_custom_scene(game_scene)
		OS.set_environment("__run_data__", "")
		
		get_viewport().set_input_as_handled()

func add_variable(variable: String, value):
	if value is Object:
		push_error("The value can be non-Object only.")
		return

	data[variable] = value
