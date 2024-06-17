@icon("res://editor/class_icons/GKEditorProperty.svg")
class_name GKEditorProperty
extends BoxContainer

var property_type:String = "Generic"
@export var property_name:String = "Property"
@export var property_description:String = "Description"
@export var source_item:GKEditorTreeItem
@export var property_id:StringName
var property_cache
var property_being_changed:bool = false

func _init():
	vertical = false

func _ready():
	var name_node:Label = Label.new()
	name_node.text = property_name
	name_node.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_node.size_flags_stretch_ratio = 2
	name_node.mouse_filter = Control.MOUSE_FILTER_STOP
	name_node.tooltip_text = "%s\n%s\n\n%s" % [property_name, property_type, property_description]
	name_node.name = "NameLabel"
	add_child(name_node)

func _process(_delta):
	if property_id != &"":
		var new_property = source_item.get(property_id)
		if new_property != property_cache:
			_update_property(new_property)
		property_cache = new_property

func _update_property(property) -> void:
	if not property_being_changed and property_id != &"":
		property_being_changed = true
		property_cache = property
		source_item.set(property_id, property)
		property_being_changed = false
