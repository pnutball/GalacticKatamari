@icon("res://editor/class_icons/GKEditorPropertyVector3.svg")
class_name GKEditorPropertyVector3
extends GKEditorProperty

func _init():
	property_type = "Vector3"
	super()

func _ready():
	super()
	var header_node:HBoxContainer = HBoxContainer.new()
	header_node.name = "Container"
	add_child(header_node)
	var x_node:SpinBox = SpinBox.new()
	x_node.size_flags_stretch_ratio = 3
	x_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	x_node.max_value = 0
	x_node.step = 0
	x_node.allow_greater = true
	x_node.allow_lesser = true
	x_node.select_all_on_focus = true
	x_node.value_changed.connect(_update_property)
	x_node.name = "x"
	header_node.add_child(x_node)
	var y_node:SpinBox = SpinBox.new()
	y_node.size_flags_stretch_ratio = 3
	y_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	y_node.max_value = 0
	y_node.step = 0
	y_node.allow_greater = true
	y_node.allow_lesser = true
	y_node.select_all_on_focus = true
	y_node.value_changed.connect(_update_property)
	y_node.name = "y"
	header_node.add_child(y_node)
	var z_node:SpinBox = SpinBox.new()
	z_node.size_flags_stretch_ratio = 3
	z_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	z_node.max_value = 0
	z_node.step = 0
	z_node.allow_greater = true
	z_node.allow_lesser = true
	z_node.select_all_on_focus = true
	z_node.value_changed.connect(_update_property)
	z_node.name = "z"
	header_node.add_child(z_node)

func _update_vec3(_property):
	_update_property(Vector3(get_node(^"Container/x").value, get_node(^"Container/y").value, get_node(^"Container/z").value))

func _update_property(property) -> void:
	if has_node(^"Container"):
		super(property)
		if not property_being_changed and property_id != &"":
			get_node(^"Container/x").set_value_no_signal(property.x)
			get_node(^"Container/y").set_value_no_signal(property.y)
			get_node(^"Container/z").set_value_no_signal(property.z)