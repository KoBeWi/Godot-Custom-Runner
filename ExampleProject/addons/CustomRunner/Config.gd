extends CustomRunner

func _can_play_scene(scene: Node) -> bool:
	return scene is Level

func _get_game_scene(for_scene: Node) -> String:
	return "res://Game.tscn"
