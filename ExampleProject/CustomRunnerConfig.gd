extends CustomRunner

func _can_play_scene(scene: Node) -> bool:
	return scene is Level2D or scene is Level3D

func _gather_variables(scene: Node):
	add_variable("mouse_pos", get_click_position())
	add_variable("camera_3d_position", get_camera_position_projected_to_ground())
	add_variable("camera_3d_yaw", get_camera_yaw())

func _get_game_scene(for_scene: Node) -> String:
	return "uid://bpv0gxik3m0dj"
