@icon("res://editor/class_icons/GKEditorPropertyString.svg")
class_name GKEditorPropertyDictEntry
extends GKEditorPropertyString

@onready var text:String:
	get:
		return get_child(1).text
	set(new_text):
		get_child(1).text = new_text

func _init():
	super()
	property_type = "Entry"

func _ready():
	super()
	get_child(0).mouse_filter = MOUSE_FILTER_STOP

func _update_property(_property) -> void:
	return
