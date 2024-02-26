@icon("res://Rollable3D.svg")
extends AnimatableBody3D

@export var InstanceName:StringName = "XX"
@export var ObjectName:String = "Debug Cube"
@export var ObjectMesh:Mesh = load("res://models/object/debug_cube_view.tres")
@export var ObjectCol:Shape3D = load("res://models/object/debug_cube.shape")

func _ready():
	$RollableObjectMesh.mesh = ObjectMesh
	$RollableObjectCollision.shape = ObjectCol
	$OnKatamariCollisionShape.shape = ObjectCol
	$ObjectAttachArea/RollableObjectAttachCollision.shape = ObjectCol
	
	name = InstanceName + "_O"
	$RollableObjectMesh.name = InstanceName + "_M"
	$RollableObjectCollision.name = InstanceName + "_C"
	$OnKatamariCollisionShape.name = InstanceName + "_K"
	$ObjectAttachArea/RollableObjectAttachCollision.name = InstanceName + "_AC"
	$ObjectAttachArea.name = InstanceName + "_A"

func _on_katamari_entered(_rid, body, shape, _locshape):
	print(body)
	print(shape)
	if body.name == "KatamariBody" and shape == 0:
		get_node(InstanceName + "_C").queue_free()
		get_node(InstanceName + "_K").reparent(body, true)
		get_node(InstanceName + "_M").reparent(body.get_node("KatamariMeshPivot"))
		queue_free()
