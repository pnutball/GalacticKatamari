@icon("res://editor/class_icons/GKEditorTreeStatic.svg")
class_name GKEditorTreeStatic
extends GKEditorTreeItem

@export_file("*.tscn") var path:String = ""

## Returns a JSON-compatible representation of this tree item and its children.
func to_json() -> Array:
	return [path]

## Creates a this tree item and its children from a source Array.
static func from_json(from:Array, name:String = "") -> GKEditorTreeStatic:
	var new_item:GKEditorTreeStatic = GKEditorTreeStatic.new()
	new_item.path = from[0]
	return new_item

## Creates property packed scenes for this node.
func send_properties(to:BoxContainer) -> void:
	super(to)
	_create_property(to, PropertyType.STRING, &"path", "Path", "The path to the .tscn file loaded by this Static.")
	return
