tool
extends EditorPlugin
class_name CustomRunner

const SHORTCUT = KEY_F7

func _can_play_scene(scene: Node) -> bool:
	return scene is Level

func _gather_variables(scene: Node):
	add_variable("mouse_pos", scene.get_local_mouse_position())

func _get_game_scene(for_scene: Node) -> String:
	return "res://Game.tscn"

static func is_custom_running() -> bool:
	return not OS.get_environment("__run_data__").empty()

static func get_variable(variable: String):
	var data: Dictionary = str2var(OS.get_environment("__run_data__"))
	if data.empty():
		push_error("Run data not found.")
	else:
		return data[variable]

var data: Dictionary

func _unhandled_key_input(event: InputEventKey):
	if get_editor_interface().is_playing_scene():
		return
	
	if event.pressed and event.scancode == SHORTCUT:
		var root: Node = get_editor_interface().get_edited_scene_root()
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
	data[variable] = value
