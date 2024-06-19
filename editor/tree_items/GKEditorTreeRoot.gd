@icon("res://editor/class_icons/GKEditorTreeRoot.svg")
class_name GKEditorTreeRoot
extends GKEditorTreeItem

## Returns a JSON-compatible representation of this tree item and its children.
func to_json():
	var dict:Dictionary = {"levels":{}}
	for child in children:
		if child is GKEditorTreeLevel:
			dict["levels"][child.level_id] = child.to_json()
	return dict

## Creates a this tree item and its children from a source Dictionary.
static func from_json(from:Dictionary, _name:String = "") -> GKEditorTreeRoot:
	var new_root:GKEditorTreeRoot = GKEditorTreeRoot.new()
	for key in from.get("levels", {}).keys():
		new_root.add_child(GKEditorTreeLevel.from_json(from.get("levels", {})[key], key))
	return new_root

## Creates a tree item for this EditorTreeItem.
func tree_sync(item:TreeItem) -> void:
	super(item)
	synced_tree_item = item
	for level in children:
		level.tree_sync(item)
	return
