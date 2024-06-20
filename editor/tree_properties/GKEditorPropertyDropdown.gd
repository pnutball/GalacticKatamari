@icon("res://editor/class_icons/GKEditorPropertyDropdown.svg")
class_name GKEditorPropertyDropdown
extends GKEditorProperty

@export var dropdown_entries:Array = []

func _init():
	super()
	property_type = "Dropdown"

func _ready():
	super()
	var option_node := OptionButton.new()
	for entry in dropdown_entries:
		if entry is String:
			option_node.add_item(entry)
	add_child(option_node)

func _update_property(property) -> void:
	super(property)
	if not property_being_changed and property_id != &"":
		get_child(1).selected = property
