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

## The base position of the dialog box, relative to the screen center.
##
## Recommended position bounds, for future reference:
## X: -750 to 750 (left to right)
## Y: -350 to 350 (top to bottom)
var BoxPosition:Vector2 = Vector2.ZERO

func _input(_event):
	if Input.is_action_just_pressed("Confirm"):
		if $DialogSizing/LettersContainer.get_child_count() == StringChars.size():
			for letter in $DialogSizing/LettersContainer.get_children():
				letter.skip()
		if $StarAnimation.is_playing():
			$StarAnimation.speed_scale = INF

func _ready():
	queue_message("Testing, |OUJI_1|,\n|vwave|one... two... three...")
	queue_message("|face:happy||hwave|HEEEERE |color:#CA52C9|WE|color:#FFFFFF| |face:happys|GO!!!!!!!!!!!")
	queue_message("|rainbow|Royal Rainbow!")
	queue_message("|face:sad|Our emotions are changing|face:anger||pulse|\nmid-sentence!")
	speak_queue()

func queue_message(unf_text:String): MessageQueue.push_back(unf_text)

## Makes King automatically say a message.
##
## unf_text is a message with formatting codes enclosed in "|".
## scripted, when true, disables behavior to continue reading the message queue.
func speak(unf_text:String, scripted:bool = false):
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
				var oujiName = "Prince"
				text += oujiName
				var colArray = []
				colArray.resize(oujiName.length())
				colArray.fill(Color("#8FC93A"))
				StringColors.append_array(colArray)
				var effArray = []
				effArray.resize(oujiName.length())
				if currentEffect != &"rainbow": effArray.fill(currentEffect)
				else: effArray.fill(&"")
				StringEffects.append_array(effArray)
				var facArray = []
				facArray.resize(oujiName.length())
				facArray.fill(currentFace)
				StringFaces.append_array(facArray)
				var shoArray = []
				shoArray.resize(oujiName.length())
				shoArray.fill(currentShocked)
				StringShocked.append_array(shoArray)
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
			elif tag.to_upper().begins_with("HWAVE"):
				currentEffect = &"hwave"
			elif tag.to_upper().begins_with("RAINBOW"):
				currentEffect = &"rainbow"
			elif tag.to_upper().begins_with("PULSE"):
				currentEffect = &"pulse"
			elif tag.to_upper().begins_with("CLEAR"):
				currentEffect = &""
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
			if substring[index] == "\'": posOffset -= Vector2(0,-6)
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
	if $DialogSizing.visible:
		$DialogSizing.modulate = Color(1,1,1,1)
		# TODO: make this account for 16:9 screen cutoff
		var tween = create_tween()
		tween.tween_property($DialogSizing, "size", Vector2(maxLength + 128, 240), 0.2) 
		tween.parallel().tween_property($DialogSizing, "position", BoxPosition - (Vector2(maxLength + 128, 240) / 2.0), 0.2)
		await get_tree().create_timer(0.2, false) 
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
		letter.delay = index * 0.1
		if (index == StringChars.size() - 1):
			letter.last_letter = true
			finalLetter = letter
		$DialogSizing/LettersContainer.add_child(letter)
	if not scripted:
		await finalLetter.last_letter_shown
		$StarAnimation.play("StarBlink")
		await $StarAnimation.animation_finished
		$DialogueFinishSound.play()
		$StarAnimation.speed_scale = 1
		continue_message_queue()

## Makes King say every message in the message queue.
func speak_queue(): if not MessageQueue.is_empty(): speak(MessageQueue.pop_front())

func continue_message_queue():
	if MessageQueue.is_empty():
		await create_tween().tween_property($DialogSizing, "modulate", Color(1,1,1,0), 0.2).finished
		if $DialogSizing.modulate != Color(1,1,1,0): $DialogSizing.visible = false
	else: 
		var nextMessage:String = MessageQueue.pop_front()
		if nextMessage == "": # Blank message closes & reopens the dialogue box.
			await create_tween().tween_property($DialogSizing, "modulate", Color(1,1,1,0), 0.2).finished
			if $DialogSizing.modulate != Color(1,1,1,0): $DialogSizing.visible = false
			continue_message_queue()
		else: speak(nextMessage)
