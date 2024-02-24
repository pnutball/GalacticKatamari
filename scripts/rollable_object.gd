@icon("res://Rollable3D.svg")
extends AnimatableBody3D



func _on_katamari_entered(_rid, body, shape, _locshape):
	print(body)
	print(shape)
	if body.name == "KatamariBody" and shape == 0:
		$RollableObjectCollision.queue_free()
		$OnKatamariCollisionShape.reparent(body, true)
		$RollableObjectMesh.reparent(body.get_node("KatamariMeshPivot"))
		queue_free()
