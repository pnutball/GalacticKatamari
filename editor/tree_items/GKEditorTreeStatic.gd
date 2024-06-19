@icon("res://editor/class_icons/GKEditorTreeStatic.svg")
class_name GKEditorTreeStatic
extends GKEditorTreeItem

@export_file("*.tscn") var path:String = ""

## Returns a JSON-compatible representation of this tree item and its children.
func to_json():
	return [path]

## Creates a this tree item and its children from a source Array.
static func from_json(from:Array, _name:String = "") -> GKEditorTreeStatic:
	var new_item:GKEditorTreeStatic = GKEditorTreeStatic.new()
	new_item.path = from[0]
	return new_item

## Creates a tree item for this EditorTreeItem.
func tree_sync(item:TreeItem) -> void:
	var this_item:TreeItem = item.create_child()
	this_item.set_icon(0, preload("res://editor/icons/static.png"))
	this_item.set_text(0, "Static %d"%(this_item.get_index() + 1))
	synced_tree_item = this_item
	return

## Creates property packed scenes for this node.
func send_properties(to:BoxContainer) -> void:
	super(to)
	_create_property(to, PropertyType.STRING, &"path", "Path", "The path to the .tscn file loaded by this Static.")
	return
