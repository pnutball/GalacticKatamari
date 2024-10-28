@icon("res://Rollable3D.svg")
class_name RollableObject3D
extends Node3D

const ENUMS = preload("res://scripts/lib/gk_object_enums.gd")

var Katamari
@export var ObjectID:StringName = &"debug_cube"
@export var InstanceName:StringName = &"XX"
@export_group("Visual")
@export var ObjectMesh:Mesh = load("res://assets/models/object/debug_cube_view.tres")
@export var ObjectCol:Shape3D = load("res://assets/models/object/debug_cube.shape")
@export var ObjectTex:Texture2D = preload("res://assets/textures/object/placeholder.png")
@export var ObjectTexRoll:Texture2D = preload("res://assets/textures/object/placeholder_roll.png")
@export var ObjectScale:float = 1
@export_group("Size Thresholds")
@export var ObjectKnockSize:float = 0
@export var ObjectRollSize:float = 0
@export var ObjectGrowSize:float = 0
@export_group("Animation")
@export var AnimationName:StringName = &"RESET"
@export var AnimationSpeed:float = 1
@export_range(0,1) var AnimationPhase:float = 0
var ObjHeightOffset:float = 0
var BodyPositionOffset:Vector3 = Vector3.ZERO
@onready var ObjectBaseRotation:Vector3 = rotation
var ObjectRotationOffset:Vector3 = Vector3.ZERO
var ObjectRollable: bool = true:
	set(new):
		if has_node("ObjectBody"):
			$ObjectBody.process_mode = Node.PROCESS_MODE_INHERIT if new else Node.PROCESS_MODE_DISABLED
	#get:
		#return $ObjectBody.process_mode == Node.PROCESS_MODE_INHERIT

@export_group("Physics")
@export var ObjectPhysicsMode:ENUMS.PhysicsBehavior

func has_parent_rollable_object() -> bool:
	return has_node(^"../..") and get_node(^"../..") is RollableObject3D

func get_parent_rollable_object() -> RollableObject3D:
	var doubleParent = get_node_or_null(^"../..")
	return doubleParent if doubleParent != null and doubleParent is RollableObject3D else null

func get_sub_objects() -> Array[RollableObject3D]:
	var output:Array[RollableObject3D] = []
	output.assign($SubObjectsRoot.get_children().filter(func(node): return node is RollableObject3D))
	return output

func has_body() -> bool:
	return has_node("ObjectBody")

func has_body_recursive() -> bool:
	return has_body() or get_sub_objects().any(func(object): return object.has_body_recursive())

func _ready():
	Katamari = StageLoader.currentKatamari
	$ObjectBody/RollableObjectMesh.mesh = ObjectMesh
	$ObjectBody/RollableObjectMesh.get("surface_material_override/0").set("shader_parameter/Texture", ObjectTex)
	$ObjectBody/RollableObjectMesh.get("surface_material_override/0").set("shader_parameter/Texture_Rolled", ObjectTexRoll)
	$ObjectBody/RollableObjectCollision.shape = ObjectCol
	$ObjectBody/OnKatamariCollisionShape.shape = ObjectCol
	$ObjectBody/ObjectAttachArea/RollableObjectAttachCollision.shape = ObjectCol
	
	ObjHeightOffset = $ObjectBody/RollableObjectMesh.get_aabb().size.y
	translate_object_local(Vector3.DOWN * ObjHeightOffset * 0.5)
	
	name = InstanceName + "_root"
	$ObjectBody/RollableObjectMesh.name = InstanceName + "_M"
	$ObjectBody/RollableObjectCollision.name = InstanceName + "_C"
	$ObjectBody/OnKatamariCollisionShape.name = InstanceName + "_K"
	$ObjectBody/ObjectAttachArea/RollableObjectAttachCollision.name = InstanceName + "_AC"
	$ObjectBody/ObjectAttachArea.name = InstanceName + "_A"
	
	$ObjectBody.scale = Vector3.ONE * ObjectScale
	
	$ObjectAnimation.speed_scale = AnimationSpeed
	$ObjectAnimation.play(AnimationName)
	$ObjectAnimation.seek(AnimationPhase)

var GravVelocity:float = 0

func _physics_process(delta):
	if has_node("ObjectBody"):
		$ObjectBody.collision_layer = 2 if Katamari.Size < ObjectKnockSize else 0
		$ObjectBody.position = ((Vector3.UP * 0.5) + BodyPositionOffset) * ObjHeightOffset
	rotation = ObjectBaseRotation + ObjectRotationOffset
	if has_parent_rollable_object() and not get_parent_rollable_object().has_body():
		#ObjectRollable = false
		#var global_trans:Transform3D = global_transform
		#reparent(get_node("/root/KatamariStageRoot"))
		#global_transform = global_trans#.translated_local(Vector3.DOWN * (ObjHeightOffset * 0.5))
		#ObjectRollable = true
		
		if ObjectPhysicsMode == ENUMS.PhysicsBehavior.GRAVITY and has_node("ObjectBody"):
			GravVelocity += ($ObjectBody.get_gravity().length() * delta * 1.5)
			$PhysicsRaycast.position = global_position
			$PhysicsRaycast.target_position = Vector3.DOWN * GravVelocity * delta
			
			$PhysicsRaycast.enabled = true
			$PhysicsRaycast.force_raycast_update()
			if $PhysicsRaycast.is_colliding():
				var offset:Vector3 = global_position - $PhysicsRaycast.get_collision_point() 
				global_position = $PhysicsRaycast.get_collision_point()
				ObjectPhysicsMode = ENUMS.PhysicsBehavior.STATIC
			else: global_position += Vector3.DOWN * GravVelocity * delta
		else: $PhysicsRaycast.enabled = false
	if not has_body_recursive():
		queue_free()

func _on_katamari_entered(_rid, body, shape, _locshape):
	print_debug(body.to_string() + "'s shape %d collided with %s (instance %s)."%[shape, ObjectID, InstanceName])
	if body == Katamari.get_node("KatamariBody") and shape == 0:
		if Katamari.Size >= ObjectRollSize:
			var mesh = get_node("ObjectBody/" + InstanceName + "_M")
			mesh.layers = 1
			get_node("ObjectBody/" + InstanceName + "_M").get("surface_material_override/0").set("shader_parameter/Rolled", true)
			get_node("ObjectBody/" + InstanceName + "_C").queue_free()
			get_node("ObjectBody/" + InstanceName + "_K").reparent(body, true)
			mesh.reparent(body.get_node("KatamariMeshPivot"))
			Katamari.grabObject(ObjectGrowSize, ObjectID, InstanceName)
			Katamari.playRollSound()
			$ObjectAnimation.pause()
			$ObjectAnimation.queue_free()
			$ObjectBody.queue_free()
			return
		elif Katamari.Size >= ObjectKnockSize:
			return
