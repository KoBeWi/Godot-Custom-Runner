extends CustomRunner

func _can_play_scene(scene: Node) -> bool:
	return scene is Level

func _gather_variables(scene: Node):
	add_variable("mouse_pos", get_click_position())

func _get_game_scene(for_scene: Node) -> String:
	return "uid://bpv0gxik3m0dj"
