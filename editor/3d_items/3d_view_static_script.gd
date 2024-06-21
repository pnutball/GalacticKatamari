extends Node3D

## The source tree object used for this 3D static.
@export var Source:GKEditorTreeStatic = null
var _path_cache:String = ""
var _change_in_progress:bool = false

func _process(_delta):
	if not _change_in_progress and Source != null and Source.path != _path_cache:
		_change_in_progress = true
		_path_cache = Source.path
		var model = preload("uid://brr0ixfenlr0r").instantiate() if not ResourceLoader.exists(Source.path) else load(Source.path).instantiate()
		for child in get_children():
			child.queue_free()
		add_child(model)
		await get_tree().create_timer(0.5).timeout
		_change_in_progress = false
