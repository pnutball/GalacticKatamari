@icon("res://Rollable3D.svg")
extends AnimatableBody3D



func _on_katamari_entered(body):
	print(body)
	if body.name == "KatamariBody":
		$RollableObjectCollision.queue_free()
		$OnKatamariCollisionShape.reparent(body, true)
		$RollableObjectMesh.reparent(body.get_node("KatamariMeshPivot"))
		queue_free()
