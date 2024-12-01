extends Node3D

@onready var camera:Camera3D = get_viewport().get_camera_3d()

func _ready():
	camera.reparent(self)
	KingFace.summon_face($KingFull/Skeleton3D/HeadAttach/KingFaceAttach)
	await get_tree().create_timer(2).timeout
	DialogueBox.queue_dialog_string("hi|break|kingmo cosmo|break|damacy")
	DialogueBox.speak_queue()
	await DialogueBox.queue_finished
	$LecAnimTree.set("parameters/conditions/LectureDone", true)
