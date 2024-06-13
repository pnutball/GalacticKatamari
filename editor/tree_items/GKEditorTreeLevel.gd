@icon("res://editor/class_icons/GKEditorTreeLevel.svg")
class_name GKEditorTreeLevel
extends GKEditorTreeItem
## The stage's level ID, ex. "test_1", "big2", "cowbear", etc.
var level_id:String = "level"
## The stage's localized name. 
## 
## Each entry is the internal language code & the corresponding text string.
var level_name:Dictionary = {"en": "New level"}
## The stage's localized description. 
## 
## Each entry is the internal language code & the corresponding text string.
var level_description:Dictionary = {"en": "Enter a description here"}


## Creates a tree item for this EditorTreeItem.
func tree_sync(item:TreeItem) -> void:
	var level_item:TreeItem = item.create_child()
	for level in children:
		level.tree_sync(level_item)
	return

## Returns a JSON-compatible representation of this tree item and its children.
func to_json() -> Dictionary:
	var modes_dict:Dictionary = {}
	for index:int in children.size():
		if children[index] is GKEditorTreeMode:
			modes_dict[children[index].mode_id] = children[index].to_json()
	var dict:Dictionary = {
		"name": level_name,
		"description": level_description,
		"modes": modes_dict
	}
	return dict

## Creates a this tree item and its children from a source Dictionary.
static func from_json(from:Dictionary, name:String = "") -> GKEditorTreeLevel:
	var new_level:GKEditorTreeLevel
	new_level.level_id = name
	new_level.level_name = from.get("name", new_level.level_name)
	new_level.level_description = from.get("description", new_level.level_description)
	return new_level

## Creates property packed scenes for this node.
func send_properties(to:BoxContainer) -> void:
	super(to)
	_create_property(to, PropertyType.PROPERTY_TYPE_STRING, &"level_id", "Level ID", "The level's unique identifier.")
	_create_property(to, PropertyType.PROPERTY_TYPE_LOCALIZED, &"level_name", "Name", "The level's name.")
	_create_property(to, PropertyType.PROPERTY_TYPE_LOCALIZED, &"level_description", "Description", "The level's description.")
	return
