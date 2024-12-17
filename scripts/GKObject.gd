@tool
@icon("res://addons/gk_editor_tools/icons/gk_object.svg")
class_name GKRollableObject
extends Node3D

const ENUMS = preload("res://scripts/lib/gk_object_enums.gd")

## The position offset when this object is parented to multiple objects.
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var position_offset:Vector3

## The rotation offset when this object is parented to multiple objects.
@export_custom(PROPERTY_HINT_RANGE, "-180,180,0.001,radians_as_degrees") var rotation_offset:Vector3

## Additional objects that this one is "parented" to.[br]
## These additional objects are factored into transform calculations alongside any child GKRollableObjects in the node tree.
@export var additional_parents:Array[GKRollableObject]

var parents:Array:
	get:
		return additional_parents + get_children(false)
var has_parents:bool:
	get:
		return not parents.is_empty()

#region Object stuff
## The Object ID (sourced from [code]res://data/objects.json[/code]) that this object uses.[br]
## The object's audio, model, collision, & textures are set based on this ID.
@export_placeholder("debug_cube") var object_id:String:
	get: return object_id
	set(new):
		object_id = new
		_refresh_object()
# the following are autogenned from the object id:
var _texture:Texture2D
var _roll_texture:Texture2D
var _model:Mesh
var _collision_shape:Shape3D
var _knock_size:float
var _roll_size:float
var _added_size:float

@export_group("Movement")
## The movement speed when the katamari [u]can't[/u] roll up/knock over this object.[br][br]
## [b]Positive numbers:[/b] The object runs away from the katamari.[br]
## [b]Negative numbers:[/b] The object approaches the katamari.[br]
## [b]Zero:[/b] This object does not move differently.
@export var speed_small:float = 0
## The movement speed when the katamari [u]can[/u] roll up/knock over this object.[br][br]
## [b]Positive numbers:[/b] The object runs away from the katamari.[br]
## [b]Negative numbers:[/b] The object approaches the katamari.[br]
## [b]Zero:[/b] This object does not move differently.
@export var speed_large:float = 0
## The distance this object will roam relative to its usual position. [br]
## If the object reaches the edge of its roam distance or bumps into a wall, it'll move in a random direction. [br]
## If set to 0, the object will not roam.
@export var roam_distance:float = 0:
	get: return roam_distance
	set(new): roam_distance = max(new, 0)
@export_group("Animation")

@export_custom(PROPERTY_HINT_RANGE, "-180,180,0.001,radians_as_degrees") var pivot_rotation:Vector3:
	set(new):
		pivot_rotation = new
		if has_node("AnimPivot"): 
			get_node("AnimPivot").rotation = new
			get_node("AnimPivot/ObjectBody").global_position = global_position
			get_node("AnimPivot/ObjectBody").global_rotation = global_rotation
	get: return pivot_rotation
	
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var pivot_offset:Vector3:
	set(new):
		pivot_offset = new
		if has_node("AnimPivot"): 
			get_node("AnimPivot").position = new
			get_node("AnimPivot/ObjectBody").global_position = global_position
			get_node("AnimPivot/ObjectBody").global_rotation = global_rotation
	get: return pivot_offset
#endregion

func _validate_property(property: Dictionary) -> void:
	if property.name in ["speed_small", "speed_large", "roaming_distance"] and get_parent() is Path3D:
		property.usage = property.usage | PROPERTY_USAGE_READ_ONLY
	elif property.name == "path_speed":
		property.usage = property.usage | PROPERTY_USAGE_READ_ONLY
	if property.name == "top_level":
		property.usage = PROPERTY_USAGE_NONE
	if property.name in ["position", "rotation"] and has_parents:
		property.usage = property.usage | PROPERTY_USAGE_READ_ONLY
	if property.name in ["position_offset", "rotation_offset"] and not has_parents:
		property.usage = property.usage | PROPERTY_USAGE_READ_ONLY

func _init() -> void:
	top_level = true

func _ready() -> void:
	#region Setup nodes
	if has_node("AnimPivot"): # prevent excess nodes
		var pivot := get_node("AnimPivot")
		remove_child(pivot)
		pivot.queue_free() 
	var node_AnimPivot := Marker3D.new()
	node_AnimPivot.name = "AnimPivot"
	node_AnimPivot.rotation = pivot_rotation
	node_AnimPivot.position = pivot_offset
	var node_ObjectBody := AnimatableBody3D.new()
	node_ObjectBody.name = "ObjectBody"
	node_ObjectBody.collision_layer = 2
	node_ObjectBody.collision_mask = 4
	var node_ObjectMesh := MeshInstance3D.new()
	node_ObjectMesh.name = "ObjectMesh"
	node_ObjectMesh.material_override = ShaderMaterial.new()
	node_ObjectMesh.material_override.resource_local_to_scene = true
	node_ObjectMesh.material_override.shader = preload("res://assets/materials/shaders/object.gdshader")
	node_ObjectMesh.material_override.shader.resource_local_to_scene = true
	var node_AttachArea := Area3D.new()
	node_AttachArea.name = "AttachArea"
	node_AttachArea.collision_layer = 2
	var node_Collision := CollisionShape3D.new()
	node_Collision.name = "Collision"
	var node_AttachCollision := CollisionShape3D.new()
	node_AttachCollision.name = "Collision"
	
	node_AnimPivot.add_child(node_ObjectBody, false, Node.INTERNAL_MODE_FRONT)
	node_ObjectBody.add_child(node_ObjectMesh, false, Node.INTERNAL_MODE_BACK)
	node_ObjectBody.add_child(node_AttachArea, false, Node.INTERNAL_MODE_BACK)
	node_ObjectBody.add_child(node_Collision, false, Node.INTERNAL_MODE_BACK)
	node_AttachArea.add_child(node_AttachCollision, false, Node.INTERNAL_MODE_BACK)
	add_child(node_AnimPivot, false, Node.INTERNAL_MODE_FRONT)
	#endregion
	
	_refresh_object()

func _refresh_object() -> void:
	var obj_attributes:Dictionary = preload("res://data/objects.json").data.get("objects", {}).get(object_id, {})
	_model = load(obj_attributes.get("view_mesh", "res://assets/models/object/debug_cube_view.tres"))
	_collision_shape = load(obj_attributes.get("collision_mesh", "res://assets/models/object/debug_cube.shape"))
	_texture = load(obj_attributes.get("texture", "res://assets/textures/object/placeholder.png"))
	_roll_texture = load(obj_attributes.get("texture_rolledup", "res://assets/textures/object/placeholder_roll.png"))
	_knock_size = obj_attributes.get("knock_size", 0.6)
	_roll_size = obj_attributes.get("roll_size", 0.6)
	_added_size = obj_attributes.get("pickup_size", 0.05)
	
	if has_node("AnimPivot/ObjectBody/ObjectMesh") and is_inside_tree():
		get_node("AnimPivot/ObjectBody/ObjectMesh").mesh = _model
		$AnimPivot/ObjectBody/ObjectMesh.material_override.set("shader_parameter/Texture", _texture)
		$AnimPivot/ObjectBody/ObjectMesh.material_override.set("shader_parameter/Texture_Rolled", _roll_texture)
	return

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if has_node("AnimPivot/ObjectBody/ObjectMesh"):
			$AnimPivot/ObjectBody/ObjectMesh.material_override.set("shader_parameter/Rolled", 
			self in EditorInterface.get_selection().get_selected_nodes())
		if is_inside_tree(): _adjust_transform()

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if is_inside_tree(): _adjust_transform()

func _adjust_transform() -> void:
	if has_parents:
		var pos:Vector3 = Vector3.ZERO
		var rot:Vector3 = Vector3.ZERO
		var count:int = 0
		for obj in parents:
			if obj != null and obj is GKRollableObject:
				pos += obj.position
				rot += obj.rotation
				count += 1
		if count > 0:
			pos /= count
			rot /= count
			transform = (Transform3D(Basis.from_euler(rot), pos)
				* Transform3D(Basis.from_euler(rotation_offset), position_offset))
		else: 
			position_offset = position
			rotation_offset = rotation
	else:
		position_offset = position
		rotation_offset = rotation
		#transform = Transform3D(Basis.from_euler(rotation_offset), position_offset)
