extends Node3D

func _ready():
	KingFace.summon_face($KingFull/Skeleton3D/HeadAttach/KingFaceAttach)

func _area_entered():
	KingFace.MoyaPosition = Vector2.ZERO
	await KingFace.recall_face()
