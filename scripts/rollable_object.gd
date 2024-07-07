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
@export var ObjectTex:Texture2D = preload("uid://bo151m2ckmef3")
@export var ObjectTexRoll:Texture2D = preload("uid://bo151m2ckmef3")
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

func _physics_process(_delta):
	if has_node("ObjectBody"):
		$ObjectBody.collision_layer = 2 if Katamari.Size < ObjectKnockSize else 0
		$ObjectBody.position = ((Vector3.UP * 0.5) + BodyPositionOffset) * ObjHeightOffset
	rotation = ObjectBaseRotation + ObjectRotationOffset

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
			#for child in $SubObjectsRoot.get_children():
				#if child is RollableObject3D:
					#child.reparent(get_node("/root/KatamariStageRoot"))
			$ObjectBody.queue_free()
			return
		elif Katamari.Size >= ObjectKnockSize:
			return
