extends Control

var _pause_in_progress:bool = false
@export var enabled:bool = false

func _input(_event):
	if enabled:
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
		elif (Input.is_action_just_pressed("Pause")
		and not $"..".Pausable 
		#and not DialogueBox.MessageQueue.is_empty()
		and KingFace.get_node("MoyaPos/SubViewportContainer").visible):
			DialogueBox.interrupt_queue()
		elif Input.is_action_just_pressed("Cancel") and get_tree().paused and not $RetryConfirmation.visible and not $QuitConfirmation.visible:
			$RetryConfirmation.visible = true
		elif Input.is_action_just_pressed("Quit to Menu") and get_tree().paused and not $RetryConfirmation.visible and not $QuitConfirmation.visible:
			$QuitConfirmation.visible = true
		elif Input.is_action_just_pressed("Quick Turn Left") and get_tree().paused and not $RetryConfirmation.visible and not $QuitConfirmation.visible and OS.is_debug_build():
			_debug_quit()

func _retry_confirmed():
	enabled = false
	$RetryAnim.play("retry")
	await get_tree().create_timer(0.5).timeout
	StageLoader.restarted = true
	get_tree().reload_current_scene()

func _debug_quit():
	enabled = false
	get_tree().change_scene_to_file("res://scenes/debug_menu.tscn")

func _quit_confirmed():
	enabled = false
	$RetryAnim.play("quit")
	await get_tree().create_timer(0.5).timeout
	StageLoader.restarted = false
	GKOverlays.load_start()
	ResourceLoader.load_threaded_request("res://scenes/title_screen.tscn", "PackedScene")
	while ResourceLoader.load_threaded_get_status("res://scenes/title_screen.tscn") != ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().process_frame
	GKOverlays.load_end()
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://scenes/title_screen.tscn"))
