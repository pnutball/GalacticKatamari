extends Control

signal talk_changed(talking:bool)
signal emotion_changed(emotion:StringName)

const TALK_NORMAL:AudioStream = preload("uid://dx5uvsocf375a")
const TALK_ANGRY:AudioStream = preload("uid://dfbwpjfdqtlw1")
const TALK_HAPPY:AudioStream = preload("uid://dye5a7b7my52f")
const TALK_SAD:AudioStream = preload("uid://c8etddlj68pm1")

## The base position of the King's face & moya, relative to the screen center.
##
## Recommended position bounds, for future reference:
## X: -750 to 750 (left to right)
## Y: -350 to 350 (top to bottom)
var MoyaPosition:Vector2 = Vector2(0,-350)
## The position modifier of the King's face & moya.
var MoyaPositionModifier:Vector2 = Vector2(0,0)

@onready var FaceAnimation = $MoyaPos/SubViewportContainer/SubViewport/KingFace/KingAnimation
var Emotion:StringName = &"Neutral":
	get:
		return Emotion
	set(newEmote):
		if Emotion != newEmote: 
			emotion_changed.emit(newEmote)
			Emotion = newEmote
var Shocked:bool = false
var Talking:bool = false:
	get:
		return Talking
	set(newTalk):
		if Talking != newTalk: 
			talk_changed.emit(newTalk)
			Talking = newTalk

func _process(_delta):
	$MoyaPos.position = MoyaPosition + MoyaPositionModifier - Vector2(170, 170)

func _talk_changed(newTalking:bool):
	if newTalking:
		match Emotion:
			&"Angry": $KingSpeechSound.stream = TALK_ANGRY
			&"Happy": $KingSpeechSound.stream = TALK_HAPPY
			&"Sad": $KingSpeechSound.stream = TALK_SAD
			_: $KingSpeechSound.stream = TALK_NORMAL
		await get_tree().create_timer(0.1, false).timeout
		if Talking: $KingSpeechSound.play()
	else: $KingSpeechSound.stop()

func _emotion_changed(newEmotion:StringName):
	var wasPlaying:bool = $KingSpeechSound.playing
	match newEmotion:
		&"Angry": $KingSpeechSound.stream = TALK_ANGRY
		&"Happy": $KingSpeechSound.stream = TALK_HAPPY
		&"Sad": $KingSpeechSound.stream = TALK_SAD
		_: $KingSpeechSound.stream = TALK_NORMAL
	if Talking and wasPlaying: $KingSpeechSound.play()
