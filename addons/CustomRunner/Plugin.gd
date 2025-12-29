@tool
extends EditorPlugin

var context: EditorContextMenuPlugin

const PLAY_SHORTCUT = "custom_runner/play"
const REPLAY_SHORTCUT = "custom_runner/replay_last"
const CONFIG_SETTING = "addons/custom_runner/config_script"
const DEFAULT_CONFIG = "uid://cotrfsbbe2ngp"

var runner: CustomRunner
var data: Dictionary
var prev_game_scene: String

func _enter_tree():
	
	context = ContextMenuPlugin.new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_2D_EDITOR, context)
	
	var make_shortcut := func(name: String, key: int) -> Shortcut:
		var event := InputEventKey.new()
		event.keycode = key
		
		var shortcut := Shortcut.new()
		shortcut.resource_name = name
		shortcut.events.append(event)
		return shortcut
	
	var settings := EditorInterface.get_editor_settings()
	if not settings.has_shortcut(PLAY_SHORTCUT):
		settings.add_shortcut(PLAY_SHORTCUT, make_shortcut.call("Play Custom Scene", KEY_F7))
	if not settings.has_shortcut(REPLAY_SHORTCUT):
		settings.add_shortcut(REPLAY_SHORTCUT, make_shortcut.call("Replay Custom Scene", KEY_MASK_SHIFT | KEY_F7))
	
	if not ProjectSettings.has_setting(CONFIG_SETTING):
		ProjectSettings.set_setting(CONFIG_SETTING, DEFAULT_CONFIG)
	
	var extensions: PackedStringArray
	for ext in ResourceLoader.get_recognized_extensions_for_type("Script"):
		if ext == "tres" or ext == "res":
			continue
		extensions.append("*.%s;Script File" % ext)
	
	ProjectSettings.set_initial_value(CONFIG_SETTING, DEFAULT_CONFIG)
	ProjectSettings.add_property_info({
		"name": CONFIG_SETTING,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE_PATH,
		"hint_string": ",".join(extensions),
	})
	
	ProjectSettings.settings_changed.connect(update_settings)
	
	load_runner()

func load_runner():
	var script_path = ProjectSettings.get_setting(CONFIG_SETTING)
	if not ResourceLoader.exists(script_path, "Script"):
		push_error("Custom Runner config file at path \"%s\" does not exist. Falling back to default" % ResourceUID.ensure_path(script_path))
		initialize_default_runner()
		return
	
	var runner_script := load(script_path) as Script
	if not runner_script:
		push_error("Failed to load Custom Runner config. Falling back to default.")
		initialize_default_runner()
		return
	
	var instance: Object = runner_script.new()
	if not instance:
		push_error("Failed to create Custom Runner config instance. Falling back to default.")
		initialize_default_runner()
		return
	
	if not instance is CustomRunner:
		push_error("Custom Runner config instance does not extend CustomRunner. Falling back to default.")
		initialize_default_runner()
		return
	
	initialize_runner(instance)

func initialize_default_runner():
	var instance: CustomRunner = load(DEFAULT_CONFIG).new()
	initialize_runner(instance)

func initialize_runner(new_runner: CustomRunner):
	runner = new_runner
	runner._add_variable.connect(func(variable: String, value: Variant): data[variable] = value)
	context.runner = runner

func update_settings():
	if ProjectSettings.check_changed_settings_in_group(CONFIG_SETTING):
		load_runner()

func _exit_tree() -> void:
	remove_context_menu_plugin(context)

func _shortcut_input(event: InputEvent) -> void:
	if EditorInterface.is_playing_scene():
		return
	
	var k := event as InputEventKey
	if not k or not k.pressed or k.echo:
		return
	
	if EditorInterface.get_editor_settings().is_shortcut(PLAY_SHORTCUT, k):
		play_scene(false)
		get_viewport().set_input_as_handled()
	elif EditorInterface.get_editor_settings().is_shortcut(REPLAY_SHORTCUT, k):
		play_scene(true)
		get_viewport().set_input_as_handled()

func play_scene(keep_data: bool) -> void:
	if keep_data:
		if data.is_empty() or prev_game_scene.is_empty():
			EditorInterface.get_editor_toaster().push_toast("CustomRunner: Can't do Quick Run before running mormally at least once.", EditorToaster.SEVERITY_WARNING)
			return
	else:
		var root: Node = EditorInterface.get_edited_scene_root()
		if not runner._can_play_scene(root):
			EditorInterface.get_editor_toaster().push_toast("CustomRunner: Invalid scene to play.")
			return
		
		data.clear()
		runner.add_variable("scene", root.scene_file_path)
		runner._gather_variables(root)
		
		var game_scene := runner._get_game_scene(root)
		if game_scene.is_empty():
			game_scene = root.scene_file_path
		
		prev_game_scene = game_scene
	
	OS.set_environment("__custom_runner_data__", var_to_str(data))
	EditorInterface.play_custom_scene(prev_game_scene)
	OS.set_environment("__custom_runner_data__", "")

class ContextMenuPlugin extends EditorContextMenuPlugin:
	var runner: CustomRunner
	
	func _popup_menu(paths: PackedStringArray) -> void:
		add_context_menu_item("Play Here", play, EditorInterface.get_editor_theme().get_icon(&"Play", &"EditorIcons"))
	
	func play(whatevers):
		runner.play_scene(false)
