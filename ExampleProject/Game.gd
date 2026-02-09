extends Node2D

func _ready():
	if CustomRunner.is_custom_running():
		var level_path = CustomRunner.get_variable("scene")
		var level = load(level_path).instantiate()
		add_child(level)

		if level is Level2D:
			var player = Sprite2D.new()
			player.texture = load("res://ExampleProject/2D/icon.png")
			player.position = CustomRunner.get_variable("mouse_pos")
			level.add_child(player)
		elif level is Level3D:
			var player = load("res://ExampleProject/3D/ThirdPersonPlayer.tscn").instantiate() as Node3D
			var camera_3d_xform = CustomRunner.get_variable("camera_3d_xform") as Transform3D
			player.transform.origin = CustomRunner.get_variable("mouse_pos_3d")
			player.rotation.y = camera_3d_xform.basis.get_euler().y
			level.add_child(player)
