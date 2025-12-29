extends CustomRunner

func _can_play_scene(scene: Node) -> bool:
	return true

func _gather_variables(scene: Node):
	if scene is CanvasItem:
		add_variable("mouse_pos", scene.get_local_mouse_position())

func _get_game_scene(for_scene: Node) -> String:
	return ""
