@icon("res://editor/class_icons/GKEditorPropertyDropdown.svg")
class_name GKEditorPropertyArray
extends GKEditorPropertyGroup

var entries:Array[GKEditorPropertyString] = []
var end_bar:HBoxContainer = HBoxContainer.new()

func _init():
	property_type = "Array"
	super()

func _ready():
	super()
	var new_button:Button = Button.new()
	new_button.icon = preload("uid://vmmd66b7dp8s")
	new_button.tooltip_text = "Add Element"
	new_button.pressed.connect(_add_entry)
	if not self is GKEditorPropertyLocalized:
		new_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	end_bar.add_child(new_button)

func _start_update():
	_update_property(entries.map(_array_map))

func _array_map(entry):
	return entry.get_child(-1).text

func _update_property(property) -> void:
	super(property)
	for index in property.size():
		if index >= entries.size():
			var entry:GKEditorPropertyString = GKEditorPropertyString.new()
			entry.get_child(-1).text_changed.connect(_start_update)
			entries.push_back(entry)
			add_child(entry)
			move_child(end_bar, -1)
		entries[index].property_name = "%d:"%index
		entries[index]._update_property(property[index])

func _add_entry():
	var entry:GKEditorPropertyString = GKEditorPropertyString.new()
	entry.get_child(-1).text_changed.connect(_start_update)
	entries.push_back(entry)
	add_child(entry)
	move_child(end_bar, -1)
	entry.property_name = "%d:"%entries.size()
