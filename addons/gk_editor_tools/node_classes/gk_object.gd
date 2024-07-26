@tool
@icon("res://addons/gk_editor_tools/icons/gk_object.svg")
class_name GKObject
extends Node3D

## Approach behavior.
##
## STATIC: Do nothing.
## SHOOT: Stand and shoot at the katamari. (Functionally identical to STATIC)
## FLEE: Run from the katamari.
## CHARGE: Run towards the katamari.
## CLOWN: Jump on top of the katamari, then fall down after a few seconds.
enum ApproachBehavior {STATIC, SHOOT, FLEE, CHARGE, CLOWN}

## Physics behavior.
##
## STATIC: Stay still.
## GRAVITY: Falls as a physics object.
## PATH: Follows a path.
## ROAM: Roams an area.
## LAUNCH: If the parent object is bumped into, launches using the direction of a Vector3.
enum PhysicsBehavior {STATIC, GRAVITY, ROAM, PATH, LAUNCH}


@onready @export var object_id:StringName = "debug_cube":
	get: return object_id
	set(new):
		object_id = new
		update_object()
@export_group("Behavior")
@export_subgroup("Approach")
@export var approach_behavior:ApproachBehavior = ApproachBehavior.STATIC
@export var approach_speed:float = 1
@export var approaches_small_katamari:bool = false
@export_subgroup("Physics")
@export var physics_behavior:PhysicsBehavior = PhysicsBehavior.STATIC
@export_file("*.tres") var physics_file:String = ""
@export var physics_speed:float = 1
@export var launch_vector:Vector3 = Vector3.ZERO
@export_subgroup("Animation")
@export var animation:StringName = &""
@export var animation_speed:float = 1
@export_range(0, 1) var animation_phase:float = 0
@export var unload_size:float = -1

## Returns a JSON-compatible representation of this tree item and its children.
func to_json():
	var sub_objects_dict:Array = []
	for child in get_children():
		if child is GKObject:
			sub_objects_dict.push_back(child.to_json())
	var dict:Dictionary = {
		"id": object_id,
		"position": [position.x, position.y, position.z],
		"rotation": [rotation.x, rotation.y, rotation.z],
		"approach_behavior": int(approach_behavior),
		"approaches_small_katamari": approaches_small_katamari,
		"approach_speed": approach_speed,
		"physics_behavior": int(physics_behavior),
		"physics_file": physics_file,
		"physics_speed": physics_speed,
		"launch_vector": [launch_vector.x,launch_vector.y,launch_vector.z],
		"animation": String(animation),
		"animation_speed": animation_speed,
		"animation_phase": animation_phase,
		"sub_objects": sub_objects_dict,
		"unload_size": unload_size
	}
	
	return dict

func _ready():
	var object_instance:MeshInstance3D = MeshInstance3D.new()
	var object_shader:ShaderMaterial = ShaderMaterial.new()
	object_shader.shader = preload("res://addons/gk_editor_tools/assets/object.gdshader")
	object_instance.material_override = object_shader
	object_instance.name = "_ObjectInstance"
	add_child(object_instance, false, Node.INTERNAL_MODE_FRONT)
	update_object()

func _process(_delta):
	scale = Vector3.ONE
	if has_node(^"_ObjectInstance"):
		$_ObjectInstance.material_override.set_shader_parameter(&"Rolled", self in EditorInterface.get_selection().get_selected_nodes())

func update_object():
	if has_node(^"_ObjectInstance"):
		var path:String = (ProjectSettings.get_setting("plugins/gk_tools/object_data_folder") + "/objects.json")
		print(path)
		var object_data:Dictionary = {}
		if ResourceLoader.exists(path):
			object_data = load(path).data.get("objects", {}).get(object_id, {
				"view_mesh": "res://addons/gk_editor_tools/assets/unknown_object.tres",
				"scale": 1,
				"texture": "res://addons/gk_editor_tools/assets/unknown_object_tex.tres",
				"texture_rolledup": "res://addons/gk_editor_tools/assets/unknown_object_tex.tres"
			})
		$_ObjectInstance.mesh = load(object_data.get("view_mesh", "res://addons/gk_editor_tools/assets/unknown_object.tres"))
		$_ObjectInstance.material_override.set_shader_parameter(&"Texture", load(object_data.get("texture", "res://addons/gk_editor_tools/assets/unknown_object_tex.tres")))
		$_ObjectInstance.material_override.set_shader_parameter(&"Texture_Rolled", load(object_data.get("texture_rolledup", "res://addons/gk_editor_tools/assets/unknown_object_tex.tres")))
		$_ObjectInstance.position = Vector3.UP * $_ObjectInstance.mesh.get_aabb().size.y * 0.5 * object_data.get("scale", 1)
		$_ObjectInstance.scale = Vector3.ONE * object_data.get("scale", 1)
