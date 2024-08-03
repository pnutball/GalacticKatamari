extends Node3D

func _ready():
	if get_tree().paused:
		get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT
	DialogueBox.visible = true
	KingFace.visible = true
	StageLoader.queue_stage(self)
	await StageLoader.stage_instantiated
	$LoadScreen/LoadAnim.play("in")
