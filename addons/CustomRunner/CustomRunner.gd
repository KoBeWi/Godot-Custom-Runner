class_name CustomRunner

## Custom Runner main script. You can customize it by modifying the Config.gd file.

const _DATA_ENV = "__custom_runner_data__"

static var _runtime_data: Dictionary

var _click_position: Vector2
var _camera_transform_3d: Transform3D
var _mouse_position_3d: Vector3

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

## Returns the position of the cursror at the time when the shortcut was pressed or when using context menu option.
## Returns infinite vector if the position couldn't be determined.
func get_click_position() -> Vector2:
	return _click_position

## Returns the transform of 3D viewport camera at the time when the shortcut was pressed.
## Returns Transform3D.IDENTITY if the camera transform couldn't be determined.
## In most 3D projects you're probably going to be interested in camera yaw: [code]xform.basis.get_euler().y[/code] and / or position: [code]xform.origin[/code].
func get_camera_transform_3d() -> Transform3D:
	return _camera_transform_3d

## Returns where, in the 3D space the mouse was pointing at the time when the shortcut was pressed.
## This is determined by projecting mouse position on the viewport camera, and tracing along the normal direction. Trace distance is configurable using the following project setting: "addons/custom_runner/ray_distance".
## Returns Vector3.ZERO if Camera3D was not found or if the trace hadn't hit anything.
func get_mouse_position_3d() -> Vector3:
	return _mouse_position_3d

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
