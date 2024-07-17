extends Control

signal talk_changed(talking:bool)
signal emotion_changed(emotion:StringName)

const TALK_NORMAL:AudioStream = preload("uid://dx5uvsocf375a")
const TALK_ANGRY:AudioStream = preload("uid://dfbwpjfdqtlw1")
const TALK_HAPPY:AudioStream = preload("uid://dye5a7b7my52f")
const TALK_SAD:AudioStream = preload("uid://c8etddlj68pm1")

const CAMERA_DEFAULT_TRANSFORM:Transform3D = Transform3D(Basis.IDENTITY, Vector3(0,0.245,4.8))
const FACE_DEFAULT_TRANSFORM:Transform3D = Transform3D(Basis.IDENTITY, Vector3.ZERO)

@onready var FaceNode:Node3D = %Moya3DOffset/KingFace
@onready var RemoteCamera:Camera3D = get_viewport().get_camera_3d()

## The base position of the King's face & moya, relative to the screen center.
##
## Recommended position bounds, for future reference:
## X: -750 to 750 (left to right)
## Y: -350 to 350 (top to bottom)
var MoyaPosition:Vector2 = Vector2(0,-350)
## The position modifier of the King's face & moya.
var MoyaPositionModifier:Vector2 = Vector2(0,0)

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

func summon_face(to:Node3D):
	FaceNode.reparent(to, false)
	FaceNode.global_position = to.global_position
	$KingFaceAnimation.anim_player = FaceNode.get_node("KingAnimation").get_path()
	RemoteCamera = to.get_viewport().get_camera_3d()
	%Moya3DOffset/Moya.visible = false
	$MoyaPos/SubViewportContainer.visible = false

func recall_face():
	$MoyaInOutAnimation.play("in_moya_only_trans_start")
	%Moya3DOffset/Moya.visible = false
	$MoyaPos/SubViewportContainer/SubViewport/Camera3D.position = RemoteCamera.global_position
	$MoyaPos/SubViewportContainer/SubViewport/Camera3D.rotation = RemoteCamera.global_rotation
	var tween = get_tree().create_tween()
	tween.tween_property(FaceNode, "global_position", Vector3.ZERO, 0.5)
	tween.parallel().tween_property(FaceNode, "global_rotation", Vector3(0,PI,0), 0.5)
	tween.parallel().tween_property(FaceNode, "scale", Vector3.ONE * 0.315, 0.5)
	tween.parallel().tween_property(RemoteCamera, "global_position", Vector3(0,0.245,-4.8), 0.5)
	tween.parallel().tween_property(RemoteCamera, "global_rotation", Vector3(0,PI,0), 0.5)
	tween.parallel().tween_property(RemoteCamera, "scale", Vector3.ONE, 0.5)
	await get_tree().create_timer(0.5).timeout
	RemoteCamera = $MoyaPos/SubViewportContainer/SubViewport/Camera3D
	FaceNode.reparent(%Moya3DOffset, true)
	$KingFaceAnimation.anim_player = FaceNode.get_node("KingAnimation").get_path()
	$Moya3D2DTransition.play("transition")
	#await $Moya3D2DTransition.animation_finished
	#$MoyaInOutAnimation.play("in_moya_only")
	await $MoyaInOutAnimation.animation_finished

func _process(_delta):
	if FaceNode == null:
		var new_face = preload("res://assets/models/king/rig/king_face.tscn").instantiate()
		%Moya3DOffset.add_child(new_face)
		FaceNode = new_face
		$KingFaceAnimation.anim_player = FaceNode.get_node("KingAnimation").get_path()
		RemoteCamera = get_viewport().get_camera_3d()
	$MoyaPos/FacePos.position = get_viewport_rect().size * Vector2(0.5,0.5) + MoyaPosition + MoyaPositionModifier
	%Moya3DOffset.position = Vector3(MoyaPosition.x + MoyaPositionModifier.x, -(MoyaPosition.y + MoyaPositionModifier.y), 0) * (0.00714286)
	%Moya3DOffset/Moya.get("surface_material_override/0").set("shader_parameter/offset", MoyaPosition + MoyaPositionModifier)
	

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
