@tool
extends EditorPlugin

func _enter_tree():
	var runner := preload("Config.gd").new()
	runner.plugin = self
	add_child(runner)
