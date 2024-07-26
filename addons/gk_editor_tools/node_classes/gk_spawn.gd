@tool
@icon("res://addons/gk_editor_tools/icons/gk_spawn.svg")
class_name GKSpawn
extends Node3D

## Returns a JSON-compatible representation of this tree item and its children.
func to_json():
	return [position.x, position.y, position.z, rotation.y]

func _ready():
	var spawn_visual := MeshInstance3D.new()
	spawn_visual.mesh = preload("res://addons/gk_editor_tools/assets/spawn.tres")
	var spawn_shader = ShaderMaterial.new()
	spawn_shader.shader = preload("res://addons/gk_editor_tools/assets/spawn.gdshader")
	spawn_visual.material_override = spawn_shader
	spawn_visual.name = "_SpawnFigurine"
	add_child(spawn_visual, false, Node.INTERNAL_MODE_FRONT)

func _process(_delta):
	rotation.x = 0
	rotation.z = 0
	scale = Vector3.ONE
	if has_node(^"_SpawnFigurine") and Engine.is_editor_hint():
		if get_node_or_null(^"../..") is GKMode:
			$_SpawnFigurine.scale = Vector3.ONE * get_node(^"../..").katamari_size * 20
		$_SpawnFigurine.material_override.set_shader_parameter(&"selected", self in EditorInterface.get_selection().get_selected_nodes())
