extends Control

var PlayMode:bool = false
var changed:bool = false
var currentFile:String = ""

signal SavePanelResponse(response:int)
signal FileDialogResponse(response:String)

func emitFileResponse(path:String = ""):
	FileDialogResponse.emit(path)

func _ready():
	OS.low_processor_usage_mode = true
	%StatusBar/StatusLabel.text = "GK Editor (%s, on %s)" % [Engine.get_architecture_name(), OS.get_name()]
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_tree().root.get_node("FPSCounter").visible = false
	%SaveButton.pressed.connect(func(): SavePanelResponse.emit(0))
	%DiscardButton.pressed.connect(func(): SavePanelResponse.emit(1))
	%CancelButton.pressed.connect(func(): SavePanelResponse.emit(2))
	StageLoader.loadStage("res://data/levels/test_1.gkl.json", "test_1")

func _process(_delta):
	%StatusBar/FPSLabel.text = "%d FPS" % [Engine.get_frames_per_second()]
	%GameView.position = Vector2i(%EditorView.get_global_rect().position)
	%GameView.size = Vector2i(%EditorView.size)
	get_window().title = "%s%s - GK Editor (%s)" % ["*" if changed else "", 
	currentFile.get_slice("/", currentFile.get_slice_count("/") - 1) if currentFile != "" else "New File", 
	Engine.get_architecture_name()]

func returnToDebug():
	if await confirmQuit() == true:
		get_tree().change_scene_to_file("res://editor/debug_menu.tscn")
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS

func returnToDesktop():
	if await confirmQuit() == true:
		get_tree().quit()

func confirmQuit():
	if not changed: return true
	$SavePanel.visible = true
	%CancelButton.grab_focus()
	var response:int = await SavePanelResponse
	match response:
		0: return await saveFile()
		1: return true
		2: return false

## Saves the current file, opening a file explorer if necessary.
func saveFile():
	if currentFile == "": return await saveFileAs()
	else:
		var file = FileAccess.open("currentFile", FileAccess.WRITE)
		if file != null:
			file.store_string(JSON.stringify(%SplitLeft.InternalLevelTree, "\t", false))
			file.close()
		return file != null

## Saves the current file to a new location.
func saveFileAs():
	%FileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	%FileDialog.visible = true
	var newPath = await FileDialogResponse
	if newPath != "": 
		currentFile = newPath
		return false
	return await saveFile()

func openFile():
	if await confirmQuit() == true:
		# CODE GOES HERE
		pass

func newFile():
	if await confirmQuit() == true:
		%SplitLeft.resetTree()
		changed = false
		currentFile = ""
	

func _on_play_button_pressed():
	PlayMode = not PlayMode
	OS.low_processor_usage_mode = not PlayMode
	%GameView.visible = PlayMode
	%SplitLeft.custom_minimum_size.x = 0 if PlayMode else 270
	$BGPanel/MarginContainer/EditorVBox/SplitMain.collapsed = PlayMode
	%SplitLeft.dragger_visibility = SplitContainer.DRAGGER_HIDDEN if PlayMode else SplitContainer.DRAGGER_VISIBLE
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

func _on_treeprop_change_made():
	changed = true
