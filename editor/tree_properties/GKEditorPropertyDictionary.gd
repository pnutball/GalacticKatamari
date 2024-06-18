@icon("res://editor/class_icons/GKEditorPropertyDropdown.svg")
class_name GKEditorPropertyDictionary
extends GKEditorPropertyGroup

var entries:Array[GKEditorPropertyDictEntry] = []
var end_bar:HBoxContainer = HBoxContainer.new()

func _init():
	super()
	property_type = "Dictionary"

func _ready():
	super()
	var new_name:LineEdit = LineEdit.new()
	new_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	end_bar.add_child(new_name)
	var new_button:Button = Button.new()
	new_button.icon = preload("uid://vmmd66b7dp8s")
	new_button.tooltip_text = "Add Element"
	new_button.pressed.connect(_button_entry_add)
	end_bar.add_child(new_button)
	add_child(end_bar)

func _start_update():
	var newDict:Dictionary = {}
	for entry in entries:
		newDict[entry.property_name] = entry.text
	_update_property(newDict)

func _update_property(property) -> void:
	super(property)
	for key in property.keys():
		var found:bool = false
		for entry in entries:
			if entry.property_name == key:
				entry.text = property[key]
				found = true
				break
		if not found:
			_add_entry(key)
			entries.back().text = property[key]

func _button_entry_add():
	_add_entry(end_bar.get_child(0).text)
	end_bar.get_child(0).text = ""

func _add_entry(entry_name:String):
	var entry:GKEditorPropertyDictEntry = GKEditorPropertyDictEntry.new()
	entry.get_child(-1).text_changed.connect(_start_update)
	entries.push_back(entry)
	entry.property_name = entry_name
	add_child(entry)
	move_child(end_bar, -1)
