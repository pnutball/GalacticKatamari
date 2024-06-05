extends Node

const ANGLE_SNAP_CURVE:Curve = preload("res://data/input_angle_curve.tres")

var lastWindowMode:int = Window.MODE_WINDOWED

func _input(_event):
	if Input.is_action_just_pressed("Fullscreen"):
		if get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
			@warning_ignore("int_as_enum_without_cast")
			get_window().mode = lastWindowMode
		else: 
			lastWindowMode = get_window().mode
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN

func snap_input_angle(input:Vector2) -> Vector2:
	return (Vector2.RIGHT * input.length()).rotated(
		ANGLE_SNAP_CURVE.sample((input.angle() / TAU) + 0.5) * PI
	)
