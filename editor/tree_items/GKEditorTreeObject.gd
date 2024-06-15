@icon("res://editor/class_icons/GKEditorTreeObject.svg")
class_name GKEditorTreeObject
extends GKEditorTreeItem

## Returns a JSON-compatible representation of this tree item and its children.
func to_json() -> Dictionary:
	
	var dict:Dictionary = {
	}
	
	return dict

## Creates a this tree item and its children from a source Dictionary.
static func from_json(from:Dictionary, name:String = "") -> GKEditorTreeObject:
	var new_item:GKEditorTreeObject = GKEditorTreeObject.new()
	# new_item.example = from.get("example", new_level.example)
	return new_item

## Creates property packed scenes for this node.
func send_properties(to:BoxContainer) -> void:
	super(to)
	# _create_property(to, PropertyType.PROPERTY_TYPE_STRING, &"level_id", "Level ID", "The level's unique identifier.")
	return
