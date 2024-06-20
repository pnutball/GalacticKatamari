@icon("res://editor/class_icons/GKEditorPropertyNumber.svg")
class_name GKEditorPropertyNumber
extends GKEditorProperty

func _init():
	property_type = "Number"
	super()

func _ready():
	super()
	var num_node:SpinBox = SpinBox.new()
	num_node.size_flags_stretch_ratio = 3
	num_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	num_node.max_value = 0
	num_node.step = 0
	num_node.allow_greater = true
	num_node.allow_lesser = true
	if property_id.contains("point"): 
		num_node.rounded = true
		num_node.suffix = "pt."
	if property_id.contains("size"): 
		num_node.step = 0.01
		num_node.suffix = "m"
	if property_id.contains("time"):
		num_node.rounded = true
		num_node.suffix = "sec."
	num_node.select_all_on_focus = true
	num_node.value_changed.connect(_update_property)
	add_child(num_node)

func _update_property(property) -> void:
	super(property)
	if not property_being_changed and property_id != &"":
		get_child(1).set_value_no_signal(property)
