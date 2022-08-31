@tool
extends EditorPlugin

func _enter_tree():
	var runner := CustomRunner.new()
	runner.plugin = self
	add_child(runner)
