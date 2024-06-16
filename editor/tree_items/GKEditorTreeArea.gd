@icon("res://editor/class_icons/GKEditorTreeArea.svg")
class_name GKEditorTreeArea
extends GKEditorTreeItem

enum AudioSize {XS, S, M, L, XL, C}

@export_range(-1, 0, 0.01, "hide_slider", "or_greater", "suffix:m") var preload_size:float = -1
@export_range(-1, 0, 0.01, "hide_slider", "or_greater", "suffix:m") var advance_size:float = -1
@export var scale:float = 1
@export_range(0, 0, 0.01, "hide_slider", "or_greater", "or_less", "suffix:m") var warp_height:float = -6
@export var audio_size:AudioSize = AudioSize.M
@export_file("*.obj") var core_model:String = "res://assets/models/core/core_generic.obj"
@export_file("*.png") var core_texture:String = "res://assets/textures/core/core_test.png"
@export_range(0, 0, 0.01, "hide_slider", "or_greater", "suffix:sec.") var time_bonus:float = 0

## Returns a JSON-compatible representation of this tree item and its children.
func to_json() -> Dictionary:
	var static_arr:Array = []
	var object_arr:Array = []
	var spawn_arr:Array = []
	for child in children:
		if child is GKEditorTreeStatic: static_arr.push_back(child.to_json())
		if child is GKEditorTreeObject: object_arr.push_back(child.to_json())
		if child is GKEditorTreeSpawn: spawn_arr.push_back(child.to_json())
	var dict:Dictionary = {
		"preload_size": preload_size,
		"advance_size": advance_size,
		"scale": scale,
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

## Creates a this tree item and its children from a source Dictionary.
static func from_json(from:Dictionary, name:String = "") -> GKEditorTreeArea:
	var new_area:GKEditorTreeArea = GKEditorTreeArea.new()
	# new_area.example = from.get("example", new_level.example)
	new_area.preload_size = from.get("preload_size", new_area.preload_size)
	new_area.advance_size = from.get("advance_size", new_area.advance_size)
	new_area.scale = from.get("scale", new_area.scale)
	new_area.audio_size = AudioSize[from.get("audio_size", "M")]
	new_area.warp_height = from.get("warp_height", new_area.warp_height)
	new_area.core_model = from.get("core_model", new_area.core_model)
	new_area.core_texture = from.get("core_texture", new_area.core_texture)
	new_area.time_bonus = from.get("time_bonus", new_area.time_bonus)
	
	for index in from.get("static", []).size():
		new_area.add_child(GKEditorTreeStatic.from_json(from.get("static", [])[index]))
	
	for index in from.get("objects", []).size():
		new_area.add_child(GKEditorTreeObject.from_json(from.get("objects", [])[index]))
	
	for index in from.get("spawn_positions", []).size():
		new_area.add_child(GKEditorTreeSpawn.from_json(from.get("spawn_positions", [])[index]))
	
	return new_area

## Creates property packed scenes for this node.
func send_properties(to:BoxContainer) -> void:
	super(to)
	_create_property(to, PropertyType.NUMBER, &"preload_size", "Preload Size", "The size at which the next area begins loading in the background.\n-1 disables background preloading for the next area.")
	_create_property(to, PropertyType.NUMBER, &"preload_size", "Advance Size", "The size at which the next area fully loads in.\n-1 disables loading the next area.")
	_create_property(to, PropertyType.NUMBER, &"scale", "Scale", "The global scale of the area.\nThis should be set to 1 divided by the average size of the katamari in this area.")
	_create_property(to, PropertyType.NUMBER, &"warp_height", "Warp Height", "The height at which the katamari Royal Warps back to a spawn point.")
	_create_dropdown_property(to, AudioSize.keys(), &"audio_size", "Audio Size", "The set of sounds used by the katamari.")
	_create_property(to, PropertyType.STRING, &"core_model", "Core Model", "The model used by the katamari's \"core\".")
	_create_property(to, PropertyType.STRING, &"core_texture", "Core Texture", "The texture used by the katamari's \"core\".")
	_create_property(to, PropertyType.NUMBER, &"time_bonus", "Time Bonus", "The amount of time earned when entering the area.")
	return
