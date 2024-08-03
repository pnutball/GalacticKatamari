extends Control

var _pause_in_progress:bool = false

func _input(_event):
	if Input.is_action_just_pressed("Pause") and not _pause_in_progress and $"..".Pausable:
		_pause_in_progress = true
		get_tree().paused = not get_tree().paused
		if get_tree().paused: $PauseSound.play()
		$PauseBG.visible = get_tree().paused
		if has_node("../Debug"): $"../Debug".modulate = Color(1,1,1,int(not get_tree().paused))
		if has_node("../Timer"): $"../Timer".visible = not get_tree().paused
		$"../SizeMeter".visible = not get_tree().paused
		$"../ObjectIndicator".visible = not get_tree().paused
		DialogueBox.visible = not get_tree().paused
		KingFace.visible = not get_tree().paused
		$PauseBG/RightSidePanel/ObjectCollect/ObjectCollectNumber.text = str($"..".ObjectQueue.size())
		var ranking = GKGlobal.calculate_rank_percentage($"..".ObjectCategoryNames, $"..".ObjectCategoryCounts)
		$PauseBG/RightSidePanel/CatRank/First/FirstTexture.texture = GKGlobal.RANK_IMAGES[ranking[0][0]]
		$PauseBG/RightSidePanel/CatRank/First/FirstLabel.text = ranking[0][1]
		$PauseBG/RightSidePanel/CatRank/Second/SecondTexture.texture = GKGlobal.RANK_IMAGES[ranking[1][0]]
		$PauseBG/RightSidePanel/CatRank/Second/SecondLabel.text = ranking[1][1]
		$PauseBG/RightSidePanel/CatRank/Third/ThirdTexture.texture = GKGlobal.RANK_IMAGES[ranking[2][0]]
		$PauseBG/RightSidePanel/CatRank/Third/ThirdLabel.text = ranking[2][1]
		
		$PauseBG/RightSidePanel/Actions/DebugInputLabel.visible = OS.is_debug_build()
		_pause_in_progress = false
	elif Input.is_action_just_pressed("Pause") and not $"..".Pausable and not DialogueBox.MessageQueue.is_empty():
		DialogueBox.interrupt_queue()
	elif Input.is_action_just_pressed("Cancel") and get_tree().paused and not $RetryConfirmation.visible and not $QuitConfirmation.visible:
		$RetryConfirmation.visible = true

func _retry_confirmed():
	# TODO: put the retry animation here
	# for now, just wait 0.5 sec
	await get_tree().create_timer(0.5).timeout
	StageLoader.restarted = true
	get_tree().reload_current_scene()
