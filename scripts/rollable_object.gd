@icon("res://Rollable3D.svg")
extends AnimatableBody3D

var Katamari
@export var ObjectID:StringName = &"debug_cube"
@export var InstanceName:StringName = &"XX"
@export var ObjectName:String = "Debug Cube"
@export var ObjectMesh:Mesh = load("res://assets/models/object/debug_cube_view.tres")
@export var ObjectCol:Shape3D = load("res://assets/models/object/debug_cube.shape")
@export var ObjectTex:Texture2D = preload("uid://bo151m2ckmef3")
@export var ObjectTexRoll:Texture2D = preload("uid://bo151m2ckmef3")
@export var ObjectKnockSize:float = 0
@export var ObjectRollSize:float = 0
@export var ObjectGrowSize:float = 0

func _ready():
	$RollableObjectMesh.mesh = ObjectMesh
	$RollableObjectMesh.material_override.albedo_texture = ObjectTex
	$RollableObjectCollision.shape = ObjectCol
	$OnKatamariCollisionShape.shape = ObjectCol
	$ObjectAttachArea/RollableObjectAttachCollision.shape = ObjectCol
	
	name = InstanceName + "_O"
	$RollableObjectMesh.name = InstanceName + "_M"
	$RollableObjectCollision.name = InstanceName + "_C"
	$OnKatamariCollisionShape.name = InstanceName + "_K"
	$ObjectAttachArea/RollableObjectAttachCollision.name = InstanceName + "_AC"
	$ObjectAttachArea.name = InstanceName + "_A"

func _process(_delta):
	collision_layer = 2 if Katamari.Size < ObjectKnockSize else 0

func _on_katamari_entered(_rid, body, shape, _locshape):
	print_debug(body.to_string() + "'s shape %d collided with %s (instance %s)."%[shape, ObjectID, InstanceName])
	if body == Katamari.get_node("KatamariBody") and shape == 0:
		if Katamari.Size >= ObjectRollSize:
			Katamari.grabObject(ObjectGrowSize, ObjectID)
			get_node(InstanceName + "_M").material_override.albedo_texture = ObjectTexRoll
			get_node(InstanceName + "_C").queue_free()
			get_node(InstanceName + "_K").reparent(body, true)
			get_node(InstanceName + "_M").reparent(body.get_node("KatamariMeshPivot"))
			body.get_parent().playRollSound()
			queue_free()
			return
		if Katamari.Size >= ObjectKnockSize:
			return
