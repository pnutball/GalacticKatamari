extends Node3D

@onready var camera:Camera3D = get_viewport().get_camera_3d()

func _ready():
	$BG3D/AnimationPlayer.play("stars_spin")
	camera.reparent(self)
	KingFace.summon_face($KingFull/Skeleton3D/HeadAttach/KingFaceAttach)
	await get_tree().create_timer(2).timeout
	DialogueBox.queue_dialog_string("...oh. Hang on. Sorry.\n We'll call you back. The demo's started.|break|Click... and... okie doke!\n Now where were We?|break|Right. The demo! We had so, so\n fabulously forgotten about it.|break|So, Prince. You're aware of\n the stage you must roll in this, yes?|break|The one for the demo. The one\n that was made for everyone to try?|break|What do you mean you weren't told\n about it!? (You're not following the script.)|break|Whatever. We'll just get rolling then!|break|...did We mention how 3D We are?")
	DialogueBox.speak_queue()
	await DialogueBox.queue_finished
	$Camera3D/ZoomOut.play("zoomout")
	$LecAnimTree.set("parameters/conditions/LectureDone", true)
