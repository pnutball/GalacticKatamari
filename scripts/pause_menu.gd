extends Control

func _input(_event):
	if Input.is_action_just_pressed("Pause"):
		$PauseBG.visible = not get_tree().paused
		get_tree().paused = not get_tree().paused
		if get_tree().paused: $PauseSound.play()
