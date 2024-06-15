@icon("res://editor/class_icons/GKEditorTreeRoot.svg")
class_name GKEditorTreeRoot
extends GKEditorTreeItem

## Returns a JSON-compatible representation of this tree item and its children.
func to_json() -> Dictionary:
	
	var dict:Dictionary = {"levels":{}}
	for child in children:
		if child is GKEditorTreeLevel:
			dict["levels"][child.level_id] = child.to_json()
	return dict

## Creates a this tree item and its children from a source Dictionary.
static func from_json(from:Dictionary, name:String = "") -> GKEditorTreeRoot:
	var new_root:GKEditorTreeRoot = GKEditorTreeRoot.new()
	for key in from.get("levels", {}).keys():
		new_root.add_child(GKEditorTreeLevel.from_json(from.get("levels", {})[key], key))
	return new_root

## Creates property packed scenes for this node.
func send_properties(to:BoxContainer) -> void:
	super(to)
	# _create_property(to, PropertyType.PROPERTY_TYPE_STRING, &"level_id", "Level ID", "The level's unique identifier.")
	return
