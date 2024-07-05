extends Control

var _pause_in_progress:bool = false

func _input(_event):
	if Input.is_action_just_pressed("Pause") and not _pause_in_progress and $"..".Pausable:
		_pause_in_progress = true
		get_tree().paused = not get_tree().paused
		if get_tree().paused: $PauseSound.play()
		$PauseBG.visible = get_tree().paused
		if has_node("../Debug"): $"../Debug".visible = not get_tree().paused
		if has_node("../Timer"): $"../Timer".visible = not get_tree().paused
		$"../SizeMeter".visible = not get_tree().paused
		$"../ObjectIndicator".visible = not get_tree().paused
		DialogueBox.visible = not get_tree().paused
		KingFace.visible = not get_tree().paused
		_pause_in_progress = false
