extends Control

var MessageQueue:Array[String] = []

const FONT = preload("res://assets/fonts/talk.tres")
const LETTER = preload("res://scenes/ui/dialogue_letter.tscn")
var StringChars:Array[String] = []
var StringXPos:Array[float] = []
var StringYPos:Array[float] = []
var StringCharWidth:Array[float] = []
var StringColors:Array[Color] = []
var StringEffects:Array[StringName] = []
var StringFaces:Array[StringName] = []
var StringShocked:Array[bool] = []
var StringShow:Array[StringName] = []

enum DialogueRevealMode {MODE_NONE = 0, MODE_IN = 1, MODE_OUT = 2, MODE_IN_OUT = 3}
const MODE_NONE := DialogueRevealMode.MODE_NONE
const MODE_IN := DialogueRevealMode.MODE_IN
const MODE_OUT := DialogueRevealMode.MODE_OUT
const MODE_IN_OUT := DialogueRevealMode.MODE_IN_OUT

var CurrentMode:DialogueRevealMode = MODE_IN_OUT

## The base position of the dialog box, relative to the screen center.
##
## Recommended position bounds, for future reference:
## X: -750 to 750 (left to right)
## Y: -350 to 350 (top to bottom)
var BoxPosition:Vector2 = Vector2.ZERO

const SIZE_COUNTER_LENGTH: Array[int] = [0, 3, 2, 1, 0]
const SIZE_COUNTER_SUFFIX: Array[String] = ["km", "m", "cm", "mm"]

func format_size(_size:float) -> String:
	var after_first_chunk:bool = false
	var chunk_no:int = 0
	var size_array:Array[int] = [floori(_size / 1000), 
	floori(_size) % 1000, 
	floori(_size * 100) % 100, 
	floori(_size * 1000) % 10]
	var size_string:String = ""
	for chunk:int in size_array.size():
		if (size_array[chunk] > 0 or after_first_chunk) and size_array.slice(chunk).any(func(a): return a > 0):
			after_first_chunk = true
			if chunk_no > 0: size_string += "%0*d%s" % [SIZE_COUNTER_LENGTH[chunk], size_array[chunk], SIZE_COUNTER_SUFFIX[chunk]]
			else: size_string += "%d%s" % [size_array[chunk], SIZE_COUNTER_SUFFIX[chunk]]
			chunk_no += 1
	return size_string if size_string != "" else "0m"

func _input(_event):
	if Input.is_action_just_pressed("Confirm"):
		if $DialogSizing/LettersContainer.get_child_count() == StringChars.size():
			for letter in $DialogSizing/LettersContainer.get_children():
				letter.skip()
		if $StarAnimation.is_playing():
			$StarAnimation.speed_scale = INF



func queue_message(unf_text:String, new_mode:DialogueRevealMode = MODE_IN_OUT): 
	if MessageQueue.is_empty():
		CurrentMode = new_mode
	else: 
		@warning_ignore("int_as_enum_without_cast")
		CurrentMode = CurrentMode & new_mode
	MessageQueue.push_back(unf_text)

## Emitted when the message queue is finished.
signal queue_finished

const TIME_SUFFIXES:Dictionary = {
	"sec": {
		"en": ["{sec} seconds", "{sec} second", "{sec} seconds"],
		"ja": ["{sec}秒"]
	},
	"min": {
		"en": ["{min} minutes", "{min} minute", "{min} minutes"],
		"ja": ["{min}分"]
	},
	"minsec": {
		"en": ["{min} min. {sec} sec."],
		"ja": ["{min}分{sec}秒"]
	}
}

func queue_dialog_string(dialogue:String, new_mode:DialogueRevealMode = MODE_IN_OUT):
	queue_message("", new_mode)
	for split in dialogue.replacen("|break|","|break|").split("|break|"):
		queue_message(split, new_mode)

func interrupt_queue():
	MessageQueue.clear()

## Makes King automatically say a message.
##
## unf_text is a message with formatting codes enclosed in "|".
## scripted, when true, disables behavior to continue reading the message queue.
func speak(unf_text:String, scripted:bool = false, instant:bool = false):
	#region Letter Creation
	for letter in $DialogSizing/LettersContainer.get_children():
		letter.queue_free()
	StringChars = []
	StringXPos = []
	StringYPos = []
	StringCharWidth = []
	StringColors = []
	StringEffects = []
	StringFaces = []
	StringShocked = []
	StringShow = []
	#endregion
	#region Text Formatting
	# Let's format this text.
	var text:String = ""
	var formattingSplits = unf_text.split("|")
	var currentColor:Color = Color("#FFFFFF")
	var currentEffect:StringName = &""
	var currentFace:StringName = &"Neutral"
	var currentShocked:bool = false
	var finalLetter
	
	for index in formattingSplits.size():
		if index % 2 == 1:
			var tag:String = formattingSplits[index]
			if tag.to_upper().begins_with("OUJI_"):
				# temp behavior
				var playerNumber:int = tag.right(-5).to_int() - 1
				var playerOuji:int = (0 if not (playerNumber >= 0 and playerNumber < GKGlobal.players.size()) 
				else GKGlobal.players[playerNumber][0])
				if playerOuji < 0 or playerOuji > GKGlobal.OujiInfo.size(): playerOuji = 0
				var oujiName = GKGlobal.OujiInfo[playerOuji].get("DialogueName")
				text += oujiName
				
				var colArray = []
				for nameIndex in oujiName.length():
					var colLength:int = GKGlobal.OujiInfo[playerOuji].get("DialogueColor").size()
					colArray.push_back(GKGlobal.OujiInfo[playerOuji].get("DialogueColor")[nameIndex % colLength])
				StringColors.append_array(colArray)
				
				var effArray = []
				effArray.resize(oujiName.length())
				effArray.fill(GKGlobal.OujiInfo[playerOuji].get("DialogueEffect"))
				StringEffects.append_array(effArray)
				
				var facArray = []
				facArray.resize(oujiName.length())
				facArray.fill(currentFace)
				StringFaces.append_array(facArray)
				
				var shoArray = []
				shoArray.resize(oujiName.length())
				shoArray.fill(currentShocked)
				StringShocked.append_array(shoArray)
				
				var goaArray = []
				goaArray.resize(oujiName.length())
				goaArray.fill(&"")
				StringShow.append_array(goaArray)
			elif tag.to_upper().begins_with("COLOR:"):
				if tag.right(-6).is_valid_html_color():
					currentColor = Color(tag.right(-6))
			elif tag.to_upper().begins_with("FACE:"):
				var face = tag.to_upper().right(-5)
				if face.begins_with("NEUTRAL") or face.begins_with("NONE"):
					currentFace = &"Neutral"
				elif face.begins_with("ANGER") or face.begins_with("ANGRY"):
					currentFace = &"Angry"
				elif face.begins_with("HAPPY"):
					currentFace = &"Happy"
				elif face.begins_with("SAD"):
					currentFace = &"Sad"
				currentShocked = face.ends_with("S")
			elif tag.to_upper().begins_with("VWAVE"):
				currentEffect = &"vwave"
			elif tag.to_upper().begins_with("JITTER"):
				currentEffect = &"jitter"
			elif tag.to_upper().begins_with("HWAVE"):
				currentEffect = &"hwave"
			elif tag.to_upper().begins_with("RAINBOW"):
				currentEffect = &"rainbow"
			elif tag.to_upper().begins_with("PULSE"):
				currentEffect = &"pulse"
			elif tag.to_upper().begins_with("CLEAR"):
				currentEffect = &""
			elif tag.to_upper().begins_with("GOAL:SIZE"):
				var goal:float = StageLoader.currentStage.get("modes", {}).get(StageLoader.currentMode, {}).get("goal_type_size", {}).get("goal_minimum")
				var size_string:String
				if goal == null: size_string = "???m"
				else: size_string = format_size(goal)
				
				text += size_string
				KingFace.get_node("MoyaPos/FacePos/LeftHand/SizeGoal/GoalCounter").text = size_string
				var colArray = []
				colArray.resize(size_string.length())
				colArray.fill(currentColor)
				StringColors.append_array(colArray)
				var effArray = []
				effArray.resize(size_string.length())
				effArray.fill(currentEffect)
				StringEffects.append_array(effArray)
				var facArray = []
				facArray.resize(size_string.length())
				facArray.fill(currentFace)
				StringFaces.append_array(facArray)
				var shoArray = []
				shoArray.resize(size_string.length())
				shoArray.fill(currentShocked)
				StringShocked.append_array(shoArray)
				var goaArray = []
				goaArray.resize(size_string.length())
				goaArray.fill(&"")
				goaArray[0] = &"size"
				StringShow.append_array(goaArray)
			elif tag.to_upper().begins_with("GOAL:POINTS"):
				var goal:int = StageLoader.currentStage.get("modes", {}).get(StageLoader.currentMode, {}).get("goal_type_points", {}).get("goal_minimum")
				var locstring:String = GKGlobal.get_localized_plural(goal, StageLoader.currentStage.get("modes", {}).get(StageLoader.currentMode, {}).get("goal_type_points", {}).get("point_name", {}))
				locstring = locstring.format({"points":goal})
				
				text += locstring
				KingFace.get_node("MoyaPos/FacePos/LeftHand/SizeGoal/GoalCounter").text = locstring
				var colArray = []
				colArray.resize(locstring.length())
				colArray.fill(currentColor)
				StringColors.append_array(colArray)
				var effArray = []
				effArray.resize(locstring.length())
				effArray.fill(currentEffect)
				StringEffects.append_array(effArray)
				var facArray = []
				facArray.resize(locstring.length())
				facArray.fill(currentFace)
				StringFaces.append_array(facArray)
				var shoArray = []
				shoArray.resize(locstring.length())
				shoArray.fill(currentShocked)
				StringShocked.append_array(shoArray)
				var goaArray = []
				goaArray.resize(locstring.length())
				goaArray.fill(&"")
				goaArray[0] = &"size"
				StringShow.append_array(goaArray)
			elif tag.to_upper().begins_with("GOAL:TIME"):
				var time:float = StageLoader.currentStage.get("modes", {}).get(StageLoader.currentMode, {}).get("time")
				var minute:int = floor(time / 60.0)
				var second:int = floori(fmod(time, 60))
				var time_string:String
				if minute == 0 and second == 0:
					time_string = GKGlobal.get_localized_plural(0, TIME_SUFFIXES["min"]).format({"min":"???"})
				elif minute == 0:
					time_string = GKGlobal.get_localized_plural(0, TIME_SUFFIXES["sec"]).format({"sec":second})
				elif second == 0:
					time_string += GKGlobal.get_localized_plural(0, TIME_SUFFIXES["min"]).format({"min":minute})
				else:
					time_string += GKGlobal.get_localized_plural(0, TIME_SUFFIXES["minsec"]).format({"min":minute, "sec":second})
				
				text += time_string
				KingFace.get_node("MoyaPos/FacePos/RightHand/TimeGoal/GoalCounter").text = time_string
				var colArray = []
				colArray.resize(time_string.length())
				colArray.fill(currentColor)
				StringColors.append_array(colArray)
				var effArray = []
				effArray.resize(time_string.length())
				effArray.fill(currentEffect)
				StringEffects.append_array(effArray)
				var facArray = []
				facArray.resize(time_string.length())
				facArray.fill(currentFace)
				StringFaces.append_array(facArray)
				var shoArray = []
				shoArray.resize(time_string.length())
				shoArray.fill(currentShocked)
				StringShocked.append_array(shoArray)
				var goaArray = []
				goaArray.resize(time_string.length())
				goaArray.fill(&"")
				goaArray[0] = &"time"
				StringShow.append_array(goaArray)
		else: 
			text += formattingSplits[index]
			var colArray = []
			colArray.resize(formattingSplits[index].length() - formattingSplits[index].count("\n"))
			colArray.fill(currentColor)
			StringColors.append_array(colArray)
			var effArray = []
			effArray.resize(formattingSplits[index].length() - formattingSplits[index].count("\n"))
			effArray.fill(currentEffect)
			StringEffects.append_array(effArray)
			var facArray = []
			facArray.resize(formattingSplits[index].length() - formattingSplits[index].count("\n"))
			facArray.fill(currentFace)
			StringFaces.append_array(facArray)
			var shoArray = []
			shoArray.resize(formattingSplits[index].length() - formattingSplits[index].count("\n"))
			shoArray.fill(currentShocked)
			StringShocked.append_array(shoArray)
			var goaArray = []
			goaArray.resize(formattingSplits[index].length() - formattingSplits[index].count("\n"))
			goaArray.fill(&"")
			StringShow.append_array(goaArray)
	#endregion
	#region Letter Setup
	# Let's set up the letters.
	var splits = text.split("\n", false)
	var height = -82 - (41 * splits.size())
	var maxLength = 0
	for substring in splits:
		height = height + 82
		var subLength:float = FONT.get_string_size(substring, HORIZONTAL_ALIGNMENT_CENTER, -1, 56).x
		if subLength > maxLength: maxLength = subLength
		var XPosArray:Array = []
		for index in substring.length():
			var posOffset:Vector2 = Vector2.ZERO
			StringChars.push_back(substring[index])
			
			StringCharWidth.push_back(FONT.get_string_size(substring[index], HORIZONTAL_ALIGNMENT_CENTER, -1, 56).x)
			# Manual adjustments for wonky letters:
			# "." gets moved up
			if substring[index] == ".": posOffset += Vector2(0,-4)
			# "'" gets moved down
			if substring[index] == "\'": posOffset += Vector2(0,6)
			# "-" gets moved down
			if substring[index] == "-": posOffset += Vector2(0,4)
			if index == 0: XPosArray.push_back(posOffset.x)
			else: XPosArray.push_back(
				FONT.get_string_size(substring.left(index + 1), HORIZONTAL_ALIGNMENT_CENTER, -1, 56).x - FONT.get_string_size(substring[index], HORIZONTAL_ALIGNMENT_CENTER, -1, 56).x
				+ posOffset.x
			)
			StringYPos.push_back(height + posOffset.y)
		XPosArray = XPosArray.map(func(x): return x - (subLength / 2.0))
		StringXPos.append_array(XPosArray)
	#endregion
	# Let's create them.
	KingFace.Emotion = StringFaces[0]
	KingFace.Shocked = StringShocked[0]
	if $DialogSizing.visible:
		$DialogSizing.modulate = Color(1,1,1,1)
		# TODO: make this account for 16:9 screen cutoff
		var tween = create_tween()
		tween.tween_property($DialogSizing, "size", Vector2(maxLength + 128, 240), 0.2) 
		tween.parallel().tween_property($DialogSizing, "position", BoxPosition - (Vector2(maxLength + 128, 240) / 2.0), 0.2)
		await get_tree().create_timer(0.2, false).timeout
	else:
		$DialogSizing.modulate = Color(1,1,1,0)
		# TODO: make this account for 16:9 screen cutoff
		$DialogSizing.size.x = maxLength + 128
		$DialogSizing.position = BoxPosition - ($DialogSizing.size / 2.0)
		$DialogSizing.visible = true
		await create_tween().tween_property($DialogSizing, "modulate", Color(1,1,1,1), 0.2).finished
	# Let's take a detour and animate King:
	KingFace.Talking = true
	for index in StringChars.size():
		var letter = LETTER.instantiate()
		letter.text = StringChars[index]
		letter.pivot_offset = Vector2(StringCharWidth[index]/2.0, 41)
		letter.position = Vector2(StringXPos[index], StringYPos[index]) + Vector2(0,8.5)
		letter.name = "Letter" + str(index)
		letter.self_modulate = StringColors[index]
		letter.effect = StringEffects[index]
		letter.face = StringFaces[index]
		letter.shocked = StringShocked[index]
		letter.goal = StringShow[index]
		letter.delay = index * 0.1
		if (index == StringChars.size() - 1):
			letter.last_letter = true
			finalLetter = letter
		$DialogSizing/LettersContainer.add_child(letter)
		if instant: letter.skip()
	if not scripted:
		await finalLetter.last_letter_shown
		$StarAnimation.play("StarBlink")
		await $StarAnimation.animation_finished
		$DialogueFinishSound.play()
		$StarAnimation.speed_scale = 1
		if KingFace.get_node("MoyaPos/FacePos/LeftHand").modulate != Color(1,1,1,0): 
			KingFace.get_node("GoalHandAnimation").play("out")
			if StageLoader.currentKatamari.has_node("SizeMeter"): 
				StageLoader.currentKatamari.get_node("SizeMeter/SizeAnimation").play("Appear")
		if KingFace.get_node("MoyaPos/FacePos/RightHand").modulate != Color(1,1,1,0):
			KingFace.get_node("TimeHandAnimation").play("out")
			if StageLoader.currentKatamari.has_node("Timer"): 
				StageLoader.currentKatamari.get_node("Timer/TimerScrollAnimation").play("Scroll")
		return

## Makes King say every message in the message queue.
##
## reveal_king, when true, plays King's reveal and unreveal animations before and after dialogue.
func speak_queue(): 
	if not (MessageQueue.is_empty() or $DialogSizing.visible): 
		KingFace.Emotion = &"Neutral"
		KingFace.Shocked = false
		if CurrentMode & MODE_IN: 
			KingFace.get_node("MoyaInOutAnimation").play(&"in")
		continue_message_queue()
		

func continue_message_queue():
	if MessageQueue.is_empty():
		await create_tween().tween_property($DialogSizing, "modulate", Color(1,1,1,0), 0.2).finished
		if $DialogSizing.modulate == Color(1,1,1,0): 
			$DialogSizing.visible = false
			queue_finished.emit()
			if CurrentMode & MODE_OUT: KingFace.get_node("MoyaInOutAnimation").play(&"out")
	else: 
		var nextMessage:String = MessageQueue.pop_front()
		if nextMessage == "": # Blank message closes & reopens the dialogue box.
			if $DialogSizing.visible:
				await create_tween().tween_property($DialogSizing, "modulate", Color(1,1,1,0), 0.2).finished
				if $DialogSizing.modulate == Color(1,1,1,0): $DialogSizing.visible = false
			continue_message_queue()
		else: 
			await speak(nextMessage)
			continue_message_queue()
