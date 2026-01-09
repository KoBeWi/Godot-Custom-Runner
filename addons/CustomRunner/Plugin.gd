@tool
extends "ExtendedEditorPlugin.gd"

var context: EditorContextMenuPlugin

const PLAY_SHORTCUT = "custom_runner/play"
const REPLAY_SHORTCUT = "custom_runner/replay_last"
const CONFIG_SETTING = "addons/custom_runner/config_script"
const DEFAULT_CONFIG = "uid://cotrfsbbe2ngp"

var runner: CustomRunner
var data: Dictionary
var prev_game_scene: String

func _init() -> void:
	add_plugin_translations_from_directory("res://addons/CustomRunner/Translations")

func _enter_tree():
	context = ContextMenuPlugin.new()
	context.plugin = self
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_2D_EDITOR, context)
	
	register_editor_shortcut("custom_runner/play", tr_extract.tr("Play Custom Scene"), KEY_F7)
	register_editor_shortcut("custom_runner/replay_last", tr_extract.tr("Replay Custom Scene"), KEY_MASK_SHIFT | KEY_F7)
	
	var extensions: PackedStringArray
	for ext in ResourceLoader.get_recognized_extensions_for_type("Script"):
		if ext == "tres" or ext == "res":
			continue
		extensions.append("*.%s;Script File" % ext)
	
	define_project_setting(CONFIG_SETTING, DEFAULT_CONFIG, PROPERTY_HINT_FILE_PATH, ",".join(extensions))
	track_project_setting(CONFIG_SETTING)
	
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
		update_click_position()
		play_scene(false)
		get_viewport().set_input_as_handled()
	elif EditorInterface.get_editor_settings().is_shortcut(REPLAY_SHORTCUT, k):
		play_scene(true)
		get_viewport().set_input_as_handled()

func play_scene(keep_data: bool) -> void:
	if keep_data:
		if data.is_empty() or prev_game_scene.is_empty():
			EditorInterface.get_editor_toaster().push_toast(tr("CustomRunner: Can't replay scene before running it normally at least once."), EditorToaster.SEVERITY_WARNING)
			return
	else:
		var root: Node = EditorInterface.get_edited_scene_root()
		if not runner._can_play_scene(root):
			EditorInterface.get_editor_toaster().push_toast(tr("CustomRunner: Invalid scene to play."))
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

func update_click_position() -> void:
	if EditorInterface.get_edited_scene_root() is CanvasItem:
		runner._click_position = EditorInterface.get_edited_scene_root().get_global_mouse_position()
	else:
		runner._click_position = Vector2.INF

class ContextMenuPlugin extends EditorContextMenuPlugin:
	var plugin: EditorPlugin
	
	func _popup_menu(paths: PackedStringArray) -> void:
		if plugin.runner._can_play_scene(EditorInterface.get_edited_scene_root()):
			add_context_menu_item(plugin.tr_extract.tr("Play Here"), play, EditorInterface.get_editor_theme().get_icon(&"Play", &"EditorIcons"))
	
	func get_position_from_popup() -> Vector2:
		var editor: Node = Engine.get_main_loop().root
		editor = editor.find_child("*CanvasItemEditor*", true, false)
		if not editor:
			return Vector2.INF
		
		var popup := editor.find_child("*SnapDialog*", false, false)
		if not popup:
			return Vector2.INF
		popup = popup.get_parent().get_child(popup.get_index(true) + 2, true)
		if not popup:
			return Vector2.INF
		
		var pos: Vector2 = Vector2(popup.position) - editor.get_screen_position() - Vector2(0, 36)
		pos = EditorInterface.get_edited_scene_root().get_viewport().global_canvas_transform.affine_inverse() * pos
		return pos
	
	func play(whatevers):
		var popup_pos := get_position_from_popup()
		if popup_pos.is_finite():
			plugin.runner._click_position = popup_pos
		else:
			plugin.update_click_position()
		
		plugin.play_scene(false)
