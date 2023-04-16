# <img src="https://github.com/KoBeWi/Godot-Custom-Runner/blob/master/Media/Icon.png" width="64" height="64"> Godot Custom Runner

Best explained with a GIF probably:
![](https://github.com/KoBeWi/Godot-Custom-Runner/blob/master/Media/ReadmeExampleGIF.gif)

As you can see, I have a typical "level" scene opened, but when I invoke custom runner with a shortcut, it will run a "game" scene instead and load the level. The "player" icon spawns at wherever I placed the cursos in the editor.

This is basically it. The CustomRunner will run a specific scene in your project and pass some data from the editor to the game (using magic). You can then use the data to e.g. load a level or place the player at the cursor position, so you can easier test your stuff.

### Configuration

First you need to configure the plugin. Open "addons/CustomRunner/Config.gd" and just edit it following the comments. Here's more detailed explaination:
`SHORTCUT = KEY_F7` - This is the key that will be used to run the project. If you press <kbd>F7</kbd> (by default), the plugin will run the scene you provided it and pass some data.

`func _can_play_scene(scene: Node) -> bool:` - This method will determine whether the current scene can be used to run the plugin. Example implementation:
```GDScript
func _can_play_scene(scene: Node) -> bool:
	return scene is Level # Runs if the currently opened scene is a Level.
```

`func _gather_variables(scene: Node):` - this is called before running scene. Put here any data you want to pass from the editor. The `scene` parameter is a reference to the root of currently opened scene. Current scene path is passed by default. You can add more data by using `add_variable("variable", value)`. `value` can't be Object-based type. Example implementation:
```GDScript
func _gather_variables(scene: Node):
	add_variable("mouse_pos", scene.get_local_mouse_position()) # Add current cursor position.
```

`func _get_game_scene(for_scene: Node) -> String:` - return the path of the main scene you want to use. Typically, there's a "game" scene in the project, which then loads a level scene and adds it as a child. If you don't have such scene, return empty string. Example implementation:
```GDScript
func _get_game_scene(for_scene: Node) -> String:
	return "res://Scenes/Game.tscn"
 ```
 
 With the example code above, pressing <kbd>F7</kbd> when you have a scene opened that has Level root node will run `Game.tscn` scene and pass `scene` variable with file path of your level and `pos` with cursor position at the time of running. This is what happens in the GIF above.
 
 ### Retrieving the data
 
There are 2 static methods to interact with the plugin from within the game:
`is_custom_running()` - returns true if the game was launched using the plugin.
`get_variable(variable: String)` - returns the value of the given variable

Example handler for the code above:
```GDScript
func _ready():
	if CustomRunner.is_custom_running():
		var level_path = CustomRunner.get_variable("scene") # Retrieve the level scene.
		var level = load(level_path).instance() # Load the level.
		add_child(level) # Add it as a child.
		var pos = CustomRunner.get_variable("mouse_pos") # Retrieve the cursor position.
		$Player.position = pos # Move the player to cursor.
```
You can test it in action in the example project.

### Quick Run

If you used Custom Runner at least once in the editor session, you can repeat the last custom run command by using <kbd>Shift</kbd> with the run shortcut (i.e. <kbd>Shift + F7</kbd> by default). Useful when you want to test a specific scene multiple times.

___
You can find all my addons on my [profile page](https://github.com/KoBeWi).

<a href='https://ko-fi.com/W7W7AD4W4' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
