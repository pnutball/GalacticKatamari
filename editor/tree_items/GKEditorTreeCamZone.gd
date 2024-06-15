@icon("res://editor/class_icons/GKEditorTreeCamZone.svg")
class_name GKEditorTreeCamZone
extends GKEditorTreeItem

@export var lower_bound:float = 0
@export var scale:float = 1.5
@export var tilt:float = -15
@export var vertical_shift:float = 0.25
@export var depth_of_field:float = 20

## Returns a JSON-compatible representation of this tree item and its children.
func to_json() -> Dictionary:
	
	var dict:Dictionary = {
		"Bound": lower_bound,
		"Scale": scale,
		"Tilt": tilt,
		"Shift": vertical_shift,
		"DOF": depth_of_field
	}
	return dict

## Creates a this tree item and its children from a source Dictionary.
static func from_json(from:Dictionary, name:String = "") -> GKEditorTreeCamZone:
	var new_zone:GKEditorTreeCamZone
	# new_item.example = from.get("example", new_level.example)
	new_zone.lower_bound = from.get("Bound", new_zone.lower_bound)
	new_zone.scale = from.get("Scale", new_zone.scale)
	new_zone.tilt = from.get("Tilt", new_zone.tilt)
	new_zone.vertical_shift = from.get("Shift", new_zone.vertical_shift)
	new_zone.depth_of_field = from.get("DOF", new_zone.depth_of_field)
	return new_zone

## Creates property packed scenes for this node.
func send_properties(to:BoxContainer) -> void:
	super(to)
	_create_property(to, PropertyType.NUMBER, &"lower_bound", "Lower Bound", "The size (meters) at which the camera goes to this camera area.")
	_create_property(to, PropertyType.NUMBER, &"scale", "Scale", "The distance between the camera and katamari (in meters).")
	_create_property(to, PropertyType.NUMBER, &"tilt", "Tilt", "The tilt of the camera (in degrees).")
	_create_property(to, PropertyType.NUMBER, &"vertical_shift", "Vert. Shift", "The vertical shift of the camera.\nPositive values move the camera upwards.")
	_create_property(to, PropertyType.NUMBER, &"depth_of_field", "DOF", "The depth-of-field distance (in meters).\n-1 disables DOF.")
	return
