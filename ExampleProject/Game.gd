extends Node2D

func _ready():
	if CustomRunner.is_custom_running():
		var level_path = CustomRunner.get_variable("scene")
		var level = load(level_path).instantiate()
		add_child(level)

		if level is Level2D:
			var pos = CustomRunner.get_variable("mouse_pos")
			$Player.position = pos
		elif level is Level3D:
			var player = load("res://ExampleProject/3D/ThirdPersonPlayer.tscn").instantiate() as Node3D
			player.transform.origin = CustomRunner.get_variable("camera_3d_position")
			player.rotation.y = CustomRunner.get_variable("camera_3d_yaw")
			level.add_child(player)
