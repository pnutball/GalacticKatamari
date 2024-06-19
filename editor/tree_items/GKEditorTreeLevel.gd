@icon("res://editor/class_icons/GKEditorTreeLevel.svg")
class_name GKEditorTreeLevel
extends GKEditorTreeItem
## The stage's level ID, ex. "test_1", "big2", "cowbear", etc.
@export var level_id:String = "level"
## The stage's localized name. 
## 
## Each entry is the internal language code & the corresponding text string.
@export var level_name:Dictionary = {"en": "New level"}
## The stage's localized description. 
## 
## Each entry is the internal language code & the corresponding text string.
@export var level_description:Dictionary = {"en": "Enter a description here"}

## Returns a JSON-compatible representation of this tree item and its children.
func to_json():
	var modes_dict:Dictionary = {}
	for child in children:
		if child is GKEditorTreeMode:
			modes_dict[child.mode_id] = child.to_json()
	var dict:Dictionary = {
		"name": level_name,
		"description": level_description,
		"modes": modes_dict
	}
	return dict

## Creates a this tree item and its children from a source Dictionary.
static func from_json(from:Dictionary, name:String = "") -> GKEditorTreeLevel:
	var new_level:GKEditorTreeLevel = GKEditorTreeLevel.new()
	new_level.level_id = name
	new_level.level_name = from.get("name", new_level.level_name)
	new_level.level_description = from.get("description", new_level.level_description)
	for key in from.get("modes", {}).keys():
		new_level.add_child(GKEditorTreeMode.from_json(from.get("modes", {})[key], key))
	return new_level

## Creates property packed scenes for this node.
func send_properties(to:BoxContainer) -> void:
	super(to)
	_create_property(to, PropertyType.STRING, &"level_id", "Level ID", "The level's unique identifier.")
	_create_property(to, PropertyType.LOCALIZED, &"level_name", "Name", "The level's name.")
	_create_property(to, PropertyType.LOCALIZED, &"level_description", "Description", "The level's description.")
	return

## Creates a tree item for this EditorTreeItem.
func tree_sync(item:TreeItem) -> void:
	var this_item:TreeItem = item.create_child()
	this_item.set_icon(0, preload("res://editor/icons/level.png"))
	this_item.set_text(0, level_id)
	synced_tree_item = this_item
	for mode in children:
		mode.tree_sync(this_item)
	return
