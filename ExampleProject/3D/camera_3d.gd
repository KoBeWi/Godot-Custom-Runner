extends Camera3D

func _enter_tree() -> void:
	if CustomRunner.is_custom_running():
		var editor_camera_xform : Transform3D = CustomRunner.get_variable("camera_3d_xform");
		print('xxx ', editor_camera_xform)
		self.global_transform = editor_camera_xform;
