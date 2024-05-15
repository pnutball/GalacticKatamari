extends Control

var PlayMode:bool = false
var changed:bool = false
var currentFile:String = ""

signal SavePanelResponse(response:int)
signal FileDialogResponse(response:String)

func emitFileResponse(path:String): FileDialogResponse.emit(path)

func emitSaveResponse(id:int = 0): SavePanelResponse.emit(id)

func _ready():
	OS.low_processor_usage_mode = true
	get_tree().auto_accept_quit = false
	%StatusBar/StatusLabel.text = "GK Editor (%s %s)" % ["64-bit" if "64" in Engine.get_architecture_name() else "32-bit", OS.get_name()]
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_tree().root.get_node("FPSCounter").visible = false
	%SaveDialog.add_button("Yes", false, "")
	%File.set_item_accelerator(0, (KEY_MASK_CTRL if OS.get_name() != "macOS" else KEY_MASK_META)|KEY_N )
	%File.set_item_accelerator(1, (KEY_MASK_CTRL if OS.get_name() != "macOS" else KEY_MASK_META)|KEY_O)
	%File.set_item_accelerator(2, (KEY_MASK_CTRL if OS.get_name() != "macOS" else KEY_MASK_META)|KEY_S)
	%File.set_item_accelerator(3, (KEY_MASK_CTRL if OS.get_name() != "macOS" else KEY_MASK_META)|KEY_MASK_SHIFT|KEY_S)
	%File.set_item_accelerator(6, (KEY_MASK_CTRL if OS.get_name() != "macOS" else KEY_MASK_META)|KEY_Q)
	%File.set_item_accelerator(5, (KEY_MASK_CTRL if OS.get_name() != "macOS" else KEY_MASK_META)|KEY_MASK_SHIFT|KEY_Q)
	%EditorView.visible = true

func _process(_delta):
	%StatusBar/FPSLabel.text = "%d FPS" % [Engine.get_frames_per_second()]
	%EditorView.position = Vector2i(%ViewsPosHelper.get_global_rect().position)
	%EditorView.size = Vector2i(%ViewsPosHelper.size)
	%GameView.position = Vector2i(%ViewsPosHelper.get_global_rect().position)
	%GameView.size = Vector2i(%ViewsPosHelper.size)
	get_window().title = "%s%s - GK Editor (%s)" % ["*" if changed else "", 
	currentFile.get_file() if currentFile != "" else "New File", 
	Engine.get_architecture_name()]
	if %SplitLeft.LevelTreeRoot.get_text(0) != currentFile.get_file() if currentFile != "" else "New File":
		%SplitLeft.LevelTreeRoot.set_text(0, currentFile.get_file() if currentFile != "" else "New File")

func returnToDebug():
	if await confirmQuit() == true:
		OS.low_processor_usage_mode = false
		get_tree().auto_accept_quit = true
		get_window().title = "Galactic Katamari"
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		get_tree().root.get_node("FPSCounter").visible = true
		get_tree().change_scene_to_file("res://scenes/debug_menu.tscn")
	else: 
		$BlockingOverlay.visible = false

func returnToDesktop():
	if await confirmQuit() == true:
		get_tree().quit()
	else: 
		$BlockingOverlay.visible = false

func confirmQuit():
	if not changed: return true
	$BlockingOverlay.visible = true
	%SaveDialog.visible = true
	%SaveDialog.get_cancel_button().grab_focus()
	var response:int = await SavePanelResponse
	match response:
		0: return await saveFile()
		1: return true
		2: return false

## Saves the current file, opening a file explorer if necessary.
func saveFile():
	$BlockingOverlay.visible = true
	if currentFile == "": return await saveFileAs()
	else:
		var file = FileAccess.open(currentFile, FileAccess.WRITE)
		if file != null:
			file.store_string(JSON.stringify({"levels": %SplitLeft.InternalLevelTree}, "\t" , false))
			file.close()
		$BlockingOverlay.visible = false
		if file != null: changed = false
		return file != null

## Saves the current file to a new location.
func saveFileAs():
	$BlockingOverlay.visible = true
	await get_tree().process_frame
	await get_tree().process_frame
	%FileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	%FileDialog.title = "Save As..."
	%FileDialog.ok_button_text = "Save"
	%FileDialog.visible = true
	var newPath:String = await FileDialogResponse
	%FileDialog.visible = false
	if newPath.length() > 0: 
		currentFile = newPath
		return await saveFile()
	else:
		$BlockingOverlay.visible = false
		return false

func openFile():
	if await confirmQuit() == true:
		$BlockingOverlay.visible = true
		%FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		%FileDialog.title = "Open"
		%FileDialog.ok_button_text = "Open"
		%FileDialog.visible = true
		var newPath:String = await FileDialogResponse
		%FileDialog.visible = false
		if newPath.length() > 0: 
			changed = false
			currentFile = newPath
			var file = FileAccess.open(currentFile, FileAccess.READ)
			if file != null:
				var fileJson = JSON.parse_string(file.get_as_text())
				if fileJson != null and "levels" in fileJson:
					%SplitLeft.openDict(fileJson.levels)
			$BlockingOverlay.visible = false
			return true
		else:
			$BlockingOverlay.visible = false
			return false
	else: 
		$BlockingOverlay.visible = false

func newFile():
	if await confirmQuit() == true:
		%SplitLeft.resetTree()
		changed = false
		currentFile = ""
	$BlockingOverlay.visible = false

func _on_play_button_pressed():
	await StageLoader.loadStagefromDict({"levels": %SplitLeft.InternalLevelTree}, %SplitLeft.lastSelectedLevel.get_text(0))
	PlayMode = not PlayMode
	OS.low_processor_usage_mode = not PlayMode
	%EditorView.visible = not PlayMode
	%SplitLeft.visible = not PlayMode
	$BGPanel/MarginContainer/EditorVBox/SplitMain/SplitRight/BrowserContainer.visible = not PlayMode
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
		await StageLoader.instantiateStage(%SplitLeft.lastSelectedMode.get_text(0), %GameView/EditorPlay)
		%GameView.visible = PlayMode
	else:
		%GameView.visible = PlayMode
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

func _on_file_menu_id_pressed(id):
	if not $BlockingOverlay.visible:
		match id:
			1: newFile()
			2: openFile()
			3: saveFile()
			4: saveFileAs()
			5: returnToDebug()
			6: returnToDesktop()
