@icon("res://editor/class_icons/GKEditorPropertyBoolean.svg")
class_name GKEditorPropertyBoolean
extends GKEditorProperty

func _init():
	property_type = "Boolean"
	super()

func _ready():
	super()
	var bool_node:CheckButton = CheckButton.new()
	bool_node.size_flags_stretch_ratio = 3
	bool_node.toggled.connect(_update_property)
	add_child(bool_node)

func _update_property(property) -> void:
	super(property)
	if not property_being_changed and property_id != &"": get_child(1).set_pressed_no_signal(property)
