class_name LoadLetter
extends Label

var letter:String
var vector:Vector2
var color:Color
var timer:float = 5

@warning_ignore("shadowed_variable")
static func create(letter:String, vector:Vector2, color:Color) -> LoadLetter:
	var new_letter:LoadLetter = LoadLetter.new()
	new_letter.letter = letter
	new_letter.vector = vector
	new_letter.color = color
	return new_letter

func _init():
	custom_minimum_size = Vector2.ONE * 100
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _ready():
	text = letter
	modulate = color
	add_theme_font_override("font", preload("res://assets/fonts/talk.tres"))
	add_theme_font_size_override("font_size", 64)
	var afterimage_1:Label = Label.new()
	afterimage_1.name = "Afterimage1"
	afterimage_1.text = letter
	afterimage_1.custom_minimum_size = Vector2.ONE * 100
	afterimage_1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	afterimage_1.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	afterimage_1.self_modulate = Color(1,1,1,2/3.0)
	afterimage_1.add_theme_font_override("font", preload("res://assets/fonts/talk.tres"))
	afterimage_1.add_theme_font_size_override("font_size", 64)
	add_child(afterimage_1, false, Node.INTERNAL_MODE_FRONT)
	var afterimage_2:Label = Label.new()
	afterimage_2.name = "Afterimage2"
	afterimage_2.text = letter
	afterimage_2.custom_minimum_size = Vector2.ONE * 100
	afterimage_2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	afterimage_2.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	afterimage_2.self_modulate = Color(1,1,1,1/3.0)
	afterimage_2.add_theme_font_override("font", preload("res://assets/fonts/talk.tres"))
	afterimage_2.add_theme_font_size_override("font_size", 64)
	afterimage_1.add_child(afterimage_2, false, Node.INTERNAL_MODE_FRONT)

func _process(delta):
	timer -= delta
	modulate = Color(color, clampf(timer, 0, 1))
	position += vector * delta
	$Afterimage1.position = vector * delta * -1
	$Afterimage1/Afterimage2.position = vector * delta * -1
	if timer <= 0: queue_free()
