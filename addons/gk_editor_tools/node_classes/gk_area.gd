@tool
@icon("res://addons/gk_editor_tools/icons/gk_area.svg")
class_name GKArea
extends Node3D

#region Settings
enum AudioSize {XS, S, M, L, XL, C}

@export_range(-1, 0, 0.01, "hide_slider", "or_greater", "suffix:m") var preload_size:float = -1
@export_range(-1, 0, 0.01, "hide_slider", "or_greater", "suffix:m") var advance_size:float = -1
@export var area_scale:float = 1
@export_range(0, 0, 0.01, "hide_slider", "or_greater", "or_less", "suffix:m") var warp_height:float = 0
@export var audio_size:AudioSize = AudioSize.M
@export_file("*.tres", "*.res") var environment:String = ""
@export_file("*.obj") var core_model:String = "res://assets/models/core/core_generic.obj"
@export_file("*.png") var core_texture:String = "res://assets/textures/core/core_test.png"
@export_range(0, 0, 0.01, "hide_slider", "or_greater", "suffix:sec.") var time_bonus:float = 0
#endregion

func _init():
	preload_size = -1
	advance_size = -1
	area_scale = 1
	warp_height = 0
	audio_size = AudioSize.M
	core_model = "res://assets/models/core/core_generic.obj"
	core_texture = "res://assets/textures/core/core_test.png"
	time_bonus = 0

## Returns a JSON-compatible representation of this tree item and its children.
func to_json():
	var static_arr:Array = []
	var object_arr:Array = []
	var spawn_arr:Array = []
	for child in get_children():
		if child is GKStatic: static_arr.push_back(child.to_json())
		if child is GKObject: object_arr.push_back(child.to_json())
		if child is GKSpawn: spawn_arr.push_back(child.to_json())
	var dict:Dictionary = {
		"preload_size": preload_size,
		"advance_size": advance_size,
		"scale": area_scale,
		"environment": environment,
		"warp_height": warp_height,
		"audio_size": AudioSize.keys()[audio_size],
		"core_model": "res://assets/models/core/core_generic.obj",
		"core_texture": "res://assets/textures/core/core_test.png",
		"time_bonus": time_bonus,
		"static": static_arr,
		"objects": object_arr,
		"spawn_positions": spawn_arr
	}
	return dict

func _ready():
	if Engine.is_editor_hint():
		var warp_plane = RootMotionView.new()
		warp_plane.name = "_WarpPlane"
		warp_plane.color = Color.MEDIUM_VIOLET_RED
		add_child(warp_plane, false, Node.INTERNAL_MODE_FRONT)

func _process(_delta):
	transform = Transform3D.IDENTITY
	if Engine.is_editor_hint() and has_node("_WarpPlane"):
		if self in EditorInterface.get_selection().get_selected_nodes():
			$_WarpPlane.visible = true
			var editor_viewport := EditorInterface.get_editor_viewport_3d()
			var editor_cam := editor_viewport.get_camera_3d()
			var distance_from_plane = absf(editor_cam.position.y - warp_height)
			
			$_WarpPlane.cell_size = area_scale * 8
			$_WarpPlane.position = Vector3(
				$_WarpPlane.cell_size * floor(editor_cam.position.x / $_WarpPlane.cell_size),
				warp_height,
				$_WarpPlane.cell_size * floor(editor_cam.position.z / $_WarpPlane.cell_size)
			)
			$_WarpPlane.radius = 512
		else: 
			$_WarpPlane.visible = false
