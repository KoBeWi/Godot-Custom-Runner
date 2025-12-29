@tool
class_name CustomRunner

## Custom Runner main script. You can customize it by modifying the Config.gd file.

const _DATA_ENV = "__custom_runner_data__"

static var _runtime_data: Dictionary

signal _add_variable(variable: String, value: Variant)

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
	return not OS.get_environment(_DATA_ENV).is_empty()

## Retrieves a passed variable's value.
static func get_variable(variable: String, default: Variant = null) -> Variant:
	assert(is_custom_running(), "Can't retrieve data if not running via plugin.")
	if _runtime_data.is_empty():
		_runtime_data = str_to_var(OS.get_environment(_DATA_ENV))

	return _runtime_data.get(variable, default)

## Adds a variable to be passed to the running game. Use in [method _gather_variables].
func add_variable(variable: String, value: Variant) -> void:
	if value is Object:
		push_error("The value can't be an Object.")
		return
	
	_add_variable.emit(variable, value)
