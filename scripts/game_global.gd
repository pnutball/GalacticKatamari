extends Node

var lastWindowMode:int = Window.MODE_WINDOWED

func _input(_event):
	if Input.is_action_just_pressed("Fullscreen"):
		if get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
			@warning_ignore("int_as_enum_without_cast")
			get_window().mode = lastWindowMode
		else: 
			lastWindowMode = get_window().mode
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
