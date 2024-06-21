extends Node3D

## The source tree object used for this 3D spawn.
@export var Source:GKEditorTreeSpawn = null

func _process(_delta):
	if Source != null:
		position = Source.position
		rotation.y = deg_to_rad(Source.rotation)
