extends Control

func _input(_event):
	if Input.is_action_just_pressed("Pause"):
		$PauseBG.visible = not get_tree().paused
		get_tree().paused = not get_tree().paused
		if has_node("../Debug"): $"../Debug".visible = not get_tree().paused
		$"../SizeMeter".visible = not get_tree().paused
		DialogueBox.visible = not get_tree().paused
		KingFace.visible = not get_tree().paused
		if get_tree().paused: $PauseSound.play()
