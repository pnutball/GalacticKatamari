extends Node

const ANGLE_SNAP_CURVE:Curve = preload("res://data/input_angle_curve.tres")

## An array of info for each Ouji ID.
##
## "FormalName": The formal name of the cousin, used outside dialogue.
## "DialogueName": The name of the cousin, used inside dialogue.
## "DialogueColor": The color of the cousin's dialogue name, as an Array[Color].
## If the DialogueColor array is shorter than the DialogueName, the array will loop.
## "DialogueEffect": The effect of the cousin's dialogue name, as a StringName.
## "Model": The cousin's rigged model.
## "ShortSound": The cousin's short sound effect.
## "LongSound": The cousin's long sound effect.
const OujiInfo:Array[Dictionary] = [
	{
		"FormalName":"???",
		"DialogueName":"???",
		"DialogueColor":[Color("#CCC")],
		"DialogueEffect":&"",
		"Model": "uid://ddvym7hjeiewb",
		"ShortSound": null,
		"LongSound": null
	}, # Fallback/error cousin
	{
		"FormalName":"The Prince",
		"DialogueName":"Prince",
		"DialogueColor":[Color("#8FC93A")],
		"DialogueEffect":&"",
		"Model": "uid://ddvym7hjeiewb",
		"ShortSound": null,
		"LongSound": null
	} # OUJI01, The Prince
]

var players:Array[Array] = [
	[01, "Player 1"]
]

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