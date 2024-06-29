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

var collectedObjects:Array[StringName] = []

var lastWindowMode:int = Window.MODE_WINDOWED

var usingController:bool = false



func _input(event):
	if event is InputEventKey or event is InputEventMouse:
		usingController = false
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		usingController = true
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

## Gets a localized string from a dictionary of translations.
func get_localized_string(input:Dictionary) -> String:
	return input.get(TranslationServer.get_locale().get_slice("_", 0), input.get("en", "MISSING STRING!"))

func get_localized_plural(count:int, input:Dictionary) -> String:
	var plurals:Array = input.get(TranslationServer.get_locale().get_slice("_", 0), input.get("en", ["MISSING STRING!"]))
	return plurals[min(count, plurals.size() - 1)]
