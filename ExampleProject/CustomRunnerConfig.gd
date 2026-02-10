extends CustomRunner

func _can_play_scene(scene: Node) -> bool:
	return scene is Level2D or scene is Level3D

func _gather_variables(scene: Node):
	add_variable("mouse_pos", get_click_position())
	add_variable("mouse_pos_3d", get_mouse_position_3d())
	add_variable("camera_3d_xform", get_camera_transform_3d())

func _get_game_scene(for_scene: Node) -> String:
	return "uid://bpv0gxik3m0dj"
