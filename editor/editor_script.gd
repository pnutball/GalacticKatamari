extends Control

var PlayMode:bool = false
var changed:bool = false

func _ready():
	OS.low_processor_usage_mode = true
	get_window().title = "GK Editor (%s)" % [Engine.get_architecture_name()]
	%StatusBar/StatusLabel.text = "GK Editor (%s, on %s)" % [Engine.get_architecture_name(), OS.get_name()]
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_tree().root.get_node("FPSCounter").visible = false
	StageLoader.loadStage("res://data/levels/test_1.gkl.json", "test_1")

func _process(_delta):
	%StatusBar/FPSLabel.text = "%d FPS" % [Engine.get_frames_per_second()]
	%GameView.position = Vector2i(%EditorView.get_global_rect().position)
	%GameView.size = Vector2i(%EditorView.size)

func returnToDebug():
	if confirmQuit():
		get_tree().change_scene_to_file("res://editor/debug_menu.tscn")
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS

func returnToDesktop():
	if confirmQuit():
		get_tree().quit()

func confirmQuit():
	return true

func _on_play_button_pressed():
	PlayMode = not PlayMode
	OS.low_processor_usage_mode = not PlayMode
	%GameView.visible = PlayMode
	$BGPanel/MarginContainer/EditorVBox/SplitMain/SplitLeft.custom_minimum_size.x = 0 if PlayMode else 270
	$BGPanel/MarginContainer/EditorVBox/SplitMain.collapsed = PlayMode
	$BGPanel/MarginContainer/EditorVBox/SplitMain/SplitLeft.dragger_visibility = SplitContainer.DRAGGER_HIDDEN if PlayMode else SplitContainer.DRAGGER_VISIBLE
	%Create.visible = not PlayMode
	if PlayMode:
		%PlayButton.text = "Stop"
		%PlayButton.icon = preload("res://editor/icons/stop.png")
		%PlayButton.release_focus()
		var play = Node.new()
		play.name = "EditorPlay"
		%GameView.add_child(play)
		StageLoader.instantiateStage("normal", %GameView/EditorPlay)
	else:
		%PlayButton.text = "Play"
		%PlayButton.icon = preload("res://editor/icons/play.png")
		if %GameView.get_node_or_null("EditorPlay") != null:
			%GameView/EditorPlay.queue_free()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if PlayMode:
			_on_play_button_pressed()
		returnToDesktop()
