extends Node3D

## The array used to transform the object.
## [0,1,2] are positions x, y, and z.
## [3] is the y rotation.
@export var TransformArray:Array = [0,0,0,0]

func _process(_delta):
	position = Vector3(TransformArray[0],TransformArray[1],TransformArray[2])
	rotation.y = deg_to_rad(TransformArray[3])
