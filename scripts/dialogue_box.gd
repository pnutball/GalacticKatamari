extends Control

const FONT = preload("res://assets/fonts/talk.tres")
const LETTER = preload("res://scenes/ui/dialogue_letter.tscn")
var StringChars:Array[String] = []
var StringXPos:Array[float] = []
var StringYPos:Array[float] = []
var StringCharWidth:Array[float] = []

func _ready():
	var height = -82
	for substring in $DialogSizing/PlaceTextSizing.text.split("\n", false):
		height = height + 82
		var subLength:float = FONT.get_string_size(substring, HORIZONTAL_ALIGNMENT_CENTER, -1, 56).x
		var XPosArray:Array[float] = []
		for index in substring.length():
			StringChars.push_back(substring[index])
			if index == 0: XPosArray.push_back(0)
			else: XPosArray.push_back(
				FONT.get_string_size(substring.left(index + 1), HORIZONTAL_ALIGNMENT_CENTER, -1, 56).x - FONT.get_string_size(substring[index], HORIZONTAL_ALIGNMENT_CENTER, -1, 56).x
			)
			StringCharWidth.push_back(FONT.get_string_size(substring[index], HORIZONTAL_ALIGNMENT_CENTER, -1, 56).x)
			StringYPos.push_back(height)
		StringXPos.append_array(XPosArray)
	for index in StringChars.size():
		
		var letter = LETTER.instantiate()
		letter.text = StringChars[index]
		letter.pivot_offset = Vector2(StringCharWidth[index]/2.0, 41)
		letter.position = Vector2(StringXPos[index], StringYPos[index]) + $DialogSizing/PlaceTextSizing.position + Vector2(0,8.5)
		letter.name = "Letter" + str(index)
		letter.delay = index * 0.1
		$DialogSizing/LettersContainer.add_child(letter)
