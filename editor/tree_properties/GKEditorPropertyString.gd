@icon("res://editor/class_icons/GKEditorPropertyString.svg")
class_name GKEditorPropertyString
extends GKEditorProperty

func _init():
	property_type = "String"
	super()

func _ready():
	super()
	var str_node:LineEdit = LineEdit.new()
	str_node.size_flags_stretch_ratio = 3
	str_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	str_node.select_all_on_focus = true
	str_node.text_changed.connect(_update_property)
	add_child(str_node)

func _update_property(property) -> void:
	super(property)
	if not property_being_changed and property_id != &"":
		get_child(1).text = property
