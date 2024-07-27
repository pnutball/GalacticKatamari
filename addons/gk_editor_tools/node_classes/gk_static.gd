@tool
@icon("res://addons/gk_editor_tools/icons/gk_static.svg")
class_name GKStatic
extends Node3D

@export_file("*.tscn") var path:String = "":
	get:
		return path
	set(new):
		path = new
		update_static()

func _init():
	path = ""

func _ready():
	update_static()

## Returns a JSON-compatible representation of this tree item and its children.
func to_json():
	return [path]

func _process(_delta):
	transform = Transform3D.IDENTITY

func update_static():
	if Engine.is_editor_hint():
		var new_static:Node = load(path).instantiate() if ResourceLoader.exists(path, "PackedScene") else preload("res://addons/gk_editor_tools/assets/error.tscn").instantiate()
		new_static.process_mode = Node.PROCESS_MODE_DISABLED
		new_static.name = "_static_scene"
		for child in get_children(true):
			child.queue_free()
		add_child(new_static, false, Node.INTERNAL_MODE_FRONT)
