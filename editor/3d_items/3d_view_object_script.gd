extends Node3D

var objectList:Dictionary = load("res://data/objects.json").data["objects"]

## The source tree object used for this 3D object.
@export var Source:GKEditorTreeObject = null
var mesh:String
var texture:String
var texture_selected:String

@onready var selected:bool = false:
	get: return selected
	set(new):
		selected = new
		if selected: 
			%RollableObjectMesh.material_override.albedo_texture = load(texture) if ResourceLoader.exists(texture) else preload("uid://bo151m2ckmef3")
		else:
			%RollableObjectMesh.material_override.albedo_texture = load(texture_selected) if ResourceLoader.exists(texture_selected) else (
				load(texture) if ResourceLoader.exists(texture) else preload("uid://bo151m2ckmef3"))

func _process(delta):
	if mesh != objectList.get("", objectList["debug_cube"])["view_mesh"]:
		mesh = objectList.get("", objectList["debug_cube"])["view_mesh"]
		%RollableObjectMesh.mesh = load(mesh)
	if texture != objectList.get("", objectList["debug_cube"])["texture"]:
		texture = objectList.get("", objectList["debug_cube"])["texture"]
	if texture_selected != objectList.get("", objectList["debug_cube"])["texture_rolledup"]:
		texture_selected = objectList.get("", objectList["debug_cube"])["texture_rolledup"]
	position = Source.position
	rotation = Source.rotation
