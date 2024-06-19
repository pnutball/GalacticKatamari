@icon("res://editor/class_icons/GKEditorTreeSpawn.svg")
class_name GKEditorTreeSpawn
extends GKEditorTreeItem

@export var position:Vector3 = Vector3.ZERO
@export_range(-180, 180, 0.001) var rotation:float = 0

## Returns a JSON-compatible representation of this tree item and its children.
func to_json():
	return [position.x, position.y, position.z, rotation]

## Creates a this tree item and its children from a source Array.
static func from_json(from:Array, _name:String = "") -> GKEditorTreeSpawn:
	var new_spawn:GKEditorTreeSpawn = GKEditorTreeSpawn.new()
	new_spawn.position = Vector3(from[0], from[1], from[2])
	new_spawn.rotation = from[3]
	return new_spawn

## Creates a tree item for this EditorTreeItem.
func tree_sync(item:TreeItem) -> void:
	var this_item:TreeItem = item.create_child()
	this_item.set_icon(0, preload("res://editor/icons/spawn.png"))
	this_item.set_text(0, "Spawn %d"%(this_item.get_index() + 1))
	synced_tree_item = this_item
	return

## Creates property packed scenes for this node.
func send_properties(to:BoxContainer) -> void:
	super(to)
	_create_property(to, PropertyType.VECTOR3, &"position", "Position", "The position where the katamari spawns.")
	_create_property(to, PropertyType.VECTOR3, &"rotation", "Rotation", "The direction the katamari initially faces.")
	return
