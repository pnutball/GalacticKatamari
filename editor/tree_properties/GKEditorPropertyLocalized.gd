@icon("res://editor/class_icons/GKEditorPropertyLocalized.svg")
class_name GKEditorPropertyLocalized
extends GKEditorPropertyDictionary

func _init():
	property_type = "Localized"
	vertical = true

func _button_entry_add():
	if TranslationServer.get_all_languages().has(end_bar.get_child(0).text):
		super()

func _add_entry(entry_name:String):
	if TranslationServer.get_all_languages().has(end_bar.get_child(0).text):
		super(entry_name)

func _update_property(property) -> void:
	if not property_being_changed and property_id != &"":
		property_being_changed = true
		property_cache = property
		source_item.set(property_id, property)
		property_being_changed = false
	var en_found:bool = false
	for entry in entries:
		if entry.property_name == "en":
			en_found = true
			break
	if not en_found:
		_add_entry("en")
	
	for key in property.keys():
		if TranslationServer.get_all_languages().has(end_bar.get_child(0).text):
			var found:bool = false
			for entry in entries:
				if entry.property_name == key:
					entry.text = property[key]
					found = true
					break
			if not found:
				_add_entry(key)
				entries.back().text = property[key]
