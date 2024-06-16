@icon("res://editor/class_icons/GKEditorTreeObject.svg")
class_name GKEditorTreeObject
extends GKEditorTreeItem

@export var object_id:StringName = "debug_cube"
@export var position:Vector3 = Vector3.ZERO
@export var rotation:Vector3 = Vector3.ZERO
@export_group("Behavior")
@export_subgroup("Approach")
@export var approach_behavior:GKObjectEnums.ApproachBehavior = GKObjectEnums.ApproachBehavior.STATIC
@export var approach_speed:float = 1
@export var approaches_small_katamari:bool = false
@export_subgroup("Physics")
@export var physics_behavior:GKObjectEnums.PhysicsBehavior = GKObjectEnums.PhysicsBehavior.STATIC
@export_file("*.tres") var physics_file:String = ""
@export var physics_speed:float = 1
@export var launch_vector:Vector3 = Vector3.ZERO
@export_subgroup("Animation")
@export var animation:StringName = &""
@export var animation_speed:float = 1
@export_range(0, 1) var animation_phase:float = 0
@export var unload_size:float = -1

## Returns a JSON-compatible representation of this tree item and its children.
func to_json() -> Dictionary:
	var sub_objects_dict:Array = []
	for child in children:
		if child is GKEditorTreeObject:
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

## Creates a this tree item and its children from a source Dictionary.
static func from_json(from:Dictionary, _name:String = "") -> GKEditorTreeObject:
	var new_item:GKEditorTreeObject = GKEditorTreeObject.new()
	new_item.object_id = from.get("id", new_item.object_id)
	new_item.position = from.get("position", new_item.position)
	new_item.rotation = from.get("rotation", new_item.rotation)
	new_item.approach_behavior = from.get("approach_behavior", new_item.approach_behavior)
	new_item.approaches_small_katamari = from.get("approaches_small_katamari", new_item.approaches_small_katamari)
	new_item.approach_speed = from.get("approach_speed", new_item.approach_speed)
	new_item.physics_behavior = from.get("physics_behavior", new_item.physics_behavior)
	new_item.physics_file = from.get("physics_file", new_item.physics_file)
	new_item.physics_speed = from.get("physics_speed", new_item.physics_speed)
	new_item.launch_vector = from.get("launch_vector", new_item.launch_vector)
	new_item.animation = from.get("animation", new_item.animation)
	new_item.animation_speed = from.get("animation_speed", new_item.animation_speed)
	new_item.animation_phase = from.get("animation_phase", new_item.animation_phase)
	new_item.unload_size = from.get("unload_size", new_item.unload_size)
	for index in from.get("sub_objects", []).size():
		new_item.add_child(GKEditorTreeObject.from_json(from.get("sub_objects", [])[index]))
	return new_item

## Creates property packed scenes for this node.
func send_properties(to:BoxContainer) -> void:
	super(to)
	_create_property(to, PropertyType.STRING, &"object_id", "Object ID", "The object's ID. If invalid, resets to the debug cube.")
	_create_property(to, PropertyType.VECTOR3, &"position", "Position", "The object's position.")
	_create_property(to, PropertyType.VECTOR3, &"rotation", "Rotation", "The object's rotation.")
	_create_property(to, PropertyType.NUMBER, &"unload_size", "Unload Size", "The size at which this object unloads.\n-1 disables unloading.")
	var group_approach := _create_property_group(to, "Approach")
	_create_dropdown_property(group_approach, GKObjectEnums.ApproachBehavior.keys(), &"approach_behavior", "Approach Behavior", "How the object reacts when approached.\nSTATIC: Do nothing.\nSHOOT: Stand and shoot at the katamari. (Functionally identical to STATIC)\nFLEE: Run from the katamari.\nCHARGE: Run towards the katamari.\nCLOWN: Jump on top of the katamari, then fall down after a few seconds.")
	_create_property(group_approach, PropertyType.NUMBER, &"approach_speed", "Approach Speed", "How fast the object moves when reacting to the katamari.")
	_create_property(group_approach, PropertyType.BOOLEAN, &"approaches_small_katamari", "Approaches Small Katamaris?", "Does the object approach katamaris smaller than its knock size?")
	var group_physics := _create_property_group(to, "Physics")
	_create_dropdown_property(to, GKObjectEnums.PhysicsBehavior.keys(), &"physics_behavior", "Physics Behavior", "How the object moves.\nSTATIC: Stay still.\nGRAVITY: Falls as a physics object.\nFollows a path.\nROAM: Roams an area.\nLAUNCH: If the parent object is bumped into, launches using the direction of a Vector3.")
	_create_property(group_physics, PropertyType.STRING, &"physics_file", "File", "The path or area used by the Path or Roam physics behavior types.")
	_create_property(group_physics, PropertyType.NUMBER, &"physics_speed", "Speed", "The movement speed of the object when moving on a path or roaming.")
	_create_property(group_physics, PropertyType.VECTOR3, &"launch_vector", "Launch Vector", "The Vector3 used when launching.")
	var group_animation := _create_property_group(to, "Animation")
	_create_property(group_animation, PropertyType.STRING, &"animation", "Animation", "The animation used by this object.\nThis plays on top of any rigged animations.")
	_create_property(group_animation, PropertyType.NUMBER, &"animation_speed", "Speed", "The speed of the animation.")
	_create_property(group_animation, PropertyType.NUMBER, &"animation_phase", "Phase", "The phase of the animation.")
	return
