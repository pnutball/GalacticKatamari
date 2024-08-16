extends Node3D

@onready var camera:Camera3D = get_viewport().get_camera_3d()

func _ready():
	camera.reparent(self)
	KingFace.summon_face($KingFull/Skeleton3D/HeadAttach/KingFaceAttach)
