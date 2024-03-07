extends Control

var PlayMode:bool = false

func _ready():
	OS.low_processor_usage_mode = true
	get_window().title = "GK Editor (%s)" % [Engine.get_architecture_name()]
	%StatusBar/StatusLabel.text = "GK Editor (%s, on %s)" % [Engine.get_architecture_name(), OS.get_name()]
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_tree().root.get_node("FPSCounter").visible = false
	StageLoader.loadStage("res://data/levels/test_1.gkl.json", "test_1")

func _process(delta):
	%StatusBar/FPSLabel.text = "%d FPS" % [Engine.get_frames_per_second()]

func returnToDebug():
	if confirmQuit():
		get_tree().change_scene_to_file("res://editor/debug_menu.tscn")

func returnToDesktop():
	if confirmQuit():
		get_tree().quit()

func confirmQuit():
	return true

func _on_play_button_pressed():
	PlayMode = not PlayMode
	OS.low_processor_usage_mode = not PlayMode
	$BGPanel/MarginContainer/EditorVBox/SplitMain/SplitLeft.visible = not PlayMode
	if PlayMode:
		%PlayButton.text = "Stop"
		%PlayButton.icon = preload("res://editor/icons/stop.png")
		%PlayButton.release_focus()
		var play = Node.new()
		play.name = "EditorPlay"
		%GameView/GameViewport.add_child(play)
		StageLoader.instantiateStage("normal", %GameView/GameViewport/EditorPlay)
		# put play view in the Window so scaling can apply
	else:
		%PlayButton.text = "Play"
		%PlayButton.icon = preload("res://editor/icons/play.png")
		if %GameView/GameViewport.get_node_or_null("EditorPlay") != null:
			%GameView/GameViewport/EditorPlay.queue_free()
