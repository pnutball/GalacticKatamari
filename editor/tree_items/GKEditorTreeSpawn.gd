@icon("res://editor/class_icons/GKEditorTreeSpawn.svg")
class_name GKEditorTreeSpawn
extends GKEditorTreeItem

@export var position:Vector3 = Vector3.ZERO
@export_range(-180, 180, 0.001) var rotation:float = 0

## Returns a JSON-compatible representation of this tree item and its children.
func to_json() -> Array:
	return [position.x, position.y, position.z, rotation]

## Creates a this tree item and its children from a source Array.
static func from_json(from:Array, name:String = "") -> GKEditorTreeSpawn:
	var new_spawn:GKEditorTreeSpawn = GKEditorTreeSpawn.new()
	new_spawn.position = Vector3(from[0], from[1], from[2])
	new_spawn.rotation = from[3]
	return new_spawn

## Creates property packed scenes for this node.
func send_properties(to:BoxContainer) -> void:
	super(to)
	_create_property(to, PropertyType.VECTOR3, &"position", "Position", "The position where the katamari spawns.")
	_create_property(to, PropertyType.VECTOR3, &"rotation", "Rotation", "The direction the katamari initially faces.")
	return
