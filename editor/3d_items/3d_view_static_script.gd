extends Node3D

## The "array" used to find the static's path.
@export var SpawnArray:Array = [""]
## A cache of the static's path, used to detect changes.
var PathCache:String = ""

func _process(_delta):
	if PathCache != SpawnArray[0]:
		for child in self.get_children():
			child.queue_free()
		PathCache = SpawnArray[0]
		var stat = preload("res://assets/ouji/OUJI_HOLDER.glb").instantiate() if not ResourceLoader.exists(PathCache, "PackedScene") else load(PathCache).instantiate()
		stat.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(stat)
