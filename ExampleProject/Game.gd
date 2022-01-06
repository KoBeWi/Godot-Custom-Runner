extends Node2D

func _ready():
	if CustomRunner.is_custom_running():
		var level_path = CustomRunner.get_variable("scene")
		var level = load(level_path).instance()
		add_child(level)
		var pos = CustomRunner.get_variable("mouse_pos")
		$Player.position = pos
