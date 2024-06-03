extends Control

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

var BoxPosition:Vector2 = Vector2.ZERO

func _ready():
	speak("Testing, |OUJI_1|,\n|vwave|one... two... three...")
	await get_tree().create_timer(5).timeout
	speak("|face:happy||hwave|HEEEERE |color:#CA52C9|WE|color:#FFFFFF| |face:happys|GO!!!!!!!!!!!")
	await get_tree().create_timer(5).timeout
	speak("|rainbow|Royal Rainbow!")
	await get_tree().create_timer(5).timeout
	speak("It's time to fix the apostrophes.")

func speak(unf_text:String):
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
	# Let's format this text.
	var text:String = ""
	var formattingSplits = unf_text.split("|")
	var currentColor:Color = Color("#FFFFFF")
	var currentEffect:StringName = &""
	var currentFace:StringName = &"Neutral"
	var currentShocked:bool = false
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
				effArray.fill(&"")
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
					currentFace = &"Anger"
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
	# Let's create them.
	$DialogSizing.size.x = maxLength + 128
	$DialogSizing.position = BoxPosition - ($DialogSizing.size / 2.0)
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
		$DialogSizing/LettersContainer.add_child(letter)
	# Let's animate King.
	# TODO: add this part crealol :)
