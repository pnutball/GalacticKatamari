@tool
@icon("res://addons/gk_editor_tools/icons/gk_object.svg")
class_name GKRollableObject
extends Node3D

const ENUMS = preload("res://scripts/lib/gk_object_enums.gd")

## The position offset when this object is parented to multiple objects.
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var position_offset:Vector3

## The rotation offset when this object is parented to multiple objects.
@export_custom(PROPERTY_HINT_RANGE, "-180,180,0.001,radians_as_degrees") var rotation_offset:Vector3

## The interpolation values used for calculating positions when this object is parented.[br]
## You likely don't need to change this.[br]
## [br]
## 0: the lowest position (-X/-Y/-Z).[br]
## 0.5: the average position.[br]
## 1: the highest position (+X/+Y/+Z).[br]
## [br]
## Defaults to averaging horizontal offsets and getting the highest vertical one.
@export_custom(PROPERTY_HINT_RANGE, "0,1,0.001") var position_lerp:Vector3 = Vector3(0.5, 1, 0.5)

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
var _name:String

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

var _animation_timer:float = 0

@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR) var play_animation:bool:
	get: return play_animation or not Engine.is_editor_hint()
	set(new): 
		play_animation = new
		if not new: _animation_timer = 0

@export_custom(PROPERTY_HINT_NONE, "suffix:m") var pivot_offset:Vector3:
	set(new):
		pivot_offset = new
		if has_node("AnimPivot"): 
			#get_node("AnimPivot").position = new
			get_node("AnimPivot/ObjectBody").position = -pivot_offset
	get: return pivot_offset
## The animation for the object's x position.
@export_subgroup("Position X")
## The duration of the animation.
## 0 disables the animation.
@export_custom(PROPERTY_HINT_NONE, "suffix:sec.") var duration_pos_x:float = 0:
	set(new): duration_pos_x = max(0, new)
	get: return duration_pos_x
## The animation's curve.
@export var anim_pos_x:Curve
## The animation's phase (the starting position in the animation).
@export_range(0, 1, 0.001) var phase_pos_x:float = 0
@export_subgroup("Position Y")
## The duration of the animation.
## 0 disables the animation.
@export_custom(PROPERTY_HINT_NONE, "suffix:sec.") var duration_pos_y:float = 0:
	set(new): duration_pos_y = max(0, new)
	get: return duration_pos_y
## The animation's curve.
@export var anim_pos_y:Curve
## The animation's phase (the starting position in the animation).
@export_range(0, 1, 0.001) var phase_pos_y:float = 0
@export_subgroup("Position Z")
## The duration of the animation.
## 0 disables the animation.
@export_custom(PROPERTY_HINT_NONE, "suffix:sec.") var duration_pos_z:float = 0:
	set(new): duration_pos_z = max(0, new)
	get: return duration_pos_z
## The animation's curve.
@export var anim_pos_z:Curve
## The animation's phase (the starting position in the animation).
@export_range(0, 1, 0.001) var phase_pos_z:float = 0
@export_subgroup("Rotation X")
## The duration of the animation.
## 0 disables the animation.
@export_custom(PROPERTY_HINT_NONE, "suffix:sec.") var duration_rot_x:float = 0:
	set(new): duration_rot_x = max(0, new)
	get: return duration_rot_x
## The animation's curve.
@export var anim_rot_x:Curve
## The animation's phase (the starting rotition in the animation).
@export_range(0, 1, 0.001) var phase_rot_x:float = 0
@export_subgroup("Rotation Y")
## The duration of the animation.
## 0 disables the animation.
@export_custom(PROPERTY_HINT_NONE, "suffix:sec.") var duration_rot_y:float = 0:
	set(new): duration_rot_y = max(0, new)
	get: return duration_rot_y
## The animation's curve.
@export var anim_rot_y:Curve
## The animation's phase (the starting rotition in the animation).
@export_range(0, 1, 0.001) var phase_rot_y:float = 0
@export_subgroup("Rotation Z")
## The duration of the animation.
## 0 disables the animation.
@export_custom(PROPERTY_HINT_NONE, "suffix:sec.") var duration_rot_z:float = 0:
	set(new): duration_rot_z = max(0, new)
	get: return duration_rot_z
## The animation's curve.
@export var anim_rot_z:Curve
## The animation's phase (the starting rotition in the animation).
@export_range(0, 1, 0.001) var phase_rot_z:float = 0
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
	if property.name in ["position_offset", "rotation_offset", "position_lerp"] and not has_parents:
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
	_name = GKGlobal.get_localized_string(obj_attributes.get("name", {"en": "Dummy"}))
	
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
		if is_inside_tree(): 
			_adjust_transform()
			_animate(delta if play_animation else 0)

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if is_inside_tree(): 
			_adjust_transform()
			_animate(delta)

func _adjust_transform() -> void:
	if has_parents and is_inside_tree():
		var pos:Vector3 = Vector3.ZERO
		var pos_min:Vector3 = Vector3(INF, INF, INF)
		var pos_max:Vector3 = Vector3(-INF, -INF, -INF)
		var rot:Vector3 = Vector3.ZERO
		var count:int = 0
		for obj in parents:
			if obj != null and obj is GKRollableObject:
				var cur_pos = (obj.get_node("AnimPivot/ObjectBody").global_position 
								if obj.has_node("AnimPivot/ObjectBody") 
								else obj.position)
				var cur_rot = (obj.get_node("AnimPivot/ObjectBody").global_rotation 
								if obj.has_node("AnimPivot/ObjectBody") 
								else obj.rotation)
				pos += cur_pos
				pos_min = pos_min.min(cur_pos)
				pos_max = pos_max.max(cur_pos)
				rot += cur_rot
				count += 1
		if count > 0:
			pos /= count
			rot /= count
			transform = (Transform3D(Basis.from_euler(rot), Vector3(
				lerpf(pos_min.x, lerpf(pos.x, pos_max.x, clamp((position_lerp.x * 2) - 1, 0, 1)), clamp(position_lerp.x * 2, 0, 1)),
				lerpf(pos_min.y, lerpf(pos.y, pos_max.y, clamp((position_lerp.y * 2) - 1, 0, 1)), clamp(position_lerp.y * 2, 0, 1)),
				lerpf(pos_min.z, lerpf(pos.z, pos_max.z, clamp((position_lerp.z * 2) - 1, 0, 1)), clamp(position_lerp.z * 2, 0, 1))
			)) * Transform3D(Basis.from_euler(rotation_offset), position_offset))
		#else: 
			#position_offset = position
			#rotation_offset = rotation
	#else:
		#position_offset = position
		#rotation_offset = rotation
		#transform = Transform3D(Basis.from_euler(rotation_offset), position_offset)

func _animate(delta:float) -> void:
	_animation_timer += delta
	get_node("AnimPivot").position = pivot_offset + Vector3(
		0 if anim_pos_x == null or is_zero_approx(duration_pos_x) else anim_pos_x.sample(fmod(_animation_timer / duration_pos_x + phase_pos_x, 1)),
		0 if anim_pos_y == null or is_zero_approx(duration_pos_y) else anim_pos_y.sample(fmod(_animation_timer / duration_pos_y + phase_pos_y, 1)),
		0 if anim_pos_z == null or is_zero_approx(duration_pos_z) else anim_pos_z.sample(fmod(_animation_timer / duration_pos_z + phase_pos_z, 1)),
	)
	get_node("AnimPivot").rotation = Vector3(
		0 if anim_rot_x == null or is_zero_approx(duration_rot_x) else deg_to_rad(anim_rot_x.sample(fmod(_animation_timer / duration_rot_x + phase_rot_x, 1))),
		0 if anim_rot_y == null or is_zero_approx(duration_rot_y) else deg_to_rad(anim_rot_y.sample(fmod(_animation_timer / duration_rot_y + phase_rot_y, 1))),
		0 if anim_rot_z == null or is_zero_approx(duration_rot_z) else deg_to_rad(anim_rot_z.sample(fmod(_animation_timer / duration_rot_z + phase_rot_z, 1))),
	)

func _get_obj_info() -> Dictionary:
	return {
		"name": _name,
		"mesh_node": get_node("AnimPivot/ObjectBody/ObjectMesh"),
		"collision_node": get_node("AnimPivot/ObjectBody/Collision"),
		"mesh": _model,
		"texture": _roll_texture
	}
