@tool
@icon("res://addons/gk_editor_tools/icons/gk_cam_zone.svg")
class_name GKCamZone
extends Node

@export var lower_bound:float = 0
@export var camera_scale:float = 1.5
@export var tilt:float = -15
@export var vertical_shift:float = 0.25
@export var depth_of_field:float = 20

func _init():
	lower_bound = 0
	camera_scale = 1.5
	tilt = -15
	vertical_shift = 0.25
	depth_of_field = 20

## Returns a JSON-compatible representation of this tree item and its children.
func to_json():
	
	var dict:Dictionary = {
		"Bound": lower_bound,
		"Scale": camera_scale,
		"Tilt": tilt,
		"Shift": vertical_shift,
		"DOF": depth_of_field
	}
	return dict

# TODO: add in-editor functionality
