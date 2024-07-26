@tool
@icon("res://addons/gk_editor_tools/icons/gk_mode.svg")
class_name GKMode
extends Node

enum GoalType {NONE, SIZE, POINTS, EXACT_SIZE}

## The mode's localized name. 
## 
## Each entry is the internal language code & the corresponding text string.
@export var mode_name:Dictionary = {"en": "Normal"}
@export_group("Music")
## The mode's default music ID.
@export var default_music:String = ""
@export var force_default_music:bool = false
@export_group("Dialogue")
## The dialogue spoken by the King before the stage loads. 
## 
## Each entry is the internal language code & the corresponding text string.
@export var pre_dialogue:Dictionary = {"en": "Put Our dialogue here..."}
## The dialogue spoken by the King before the stage begins. 
## 
## Each entry is the internal language code & the corresponding text string.
@export var start_dialogue:Dictionary = {"en": "Put Our dialogue here."}
## The dialogue spoken by the King after pressing Retry. 
## 
## Each entry is the internal language code & the corresponding text string.
@export var retry_dialogue:Dictionary = {"en": "Put Our dialogue here."}
## The dialogue spoken by the King after winning the stage. 
## 
## Each entry is the internal language code & the corresponding text string.
@export var win_dialogue:Dictionary = {"en": "Put Our dialogue here!"}
## The dialogue spoken by the King after failing the stage. 
## 
## Each entry is the internal language code & the corresponding text string.
@export var fail_dialogue:Dictionary = {"en": "PUT OUR DIALOGUE HERE!!!"}
## The dialogue spoken by the King during the results screen before scoring. 
## 
## Each entry is the internal language code & the corresponding text string.
@export var result_dialogue:Dictionary = {"en": "Put Our dialogue here."}
@export_group("Katamari")
@export var katamari_size:float = 1
@export var katamari_speed:float = 4.5
@export var can_katamari_dash:bool = true
@export var can_katamari_turn:bool = true
@export var can_katamari_dialogue_move:bool = true
@export_group("Goals")
## The stage's goal type.
##
## NONE shows just the katamari's size, and optionally the number of objects rolled and a quit button (for Eternal or a scoreless level)
## SIZE has a required minimum size, and an optional points counter (for post-WLK style Roll it Big stages)
## POINTS has a required minimum point count, and a size counter (for gimmick levels)
## EXACT_SIZE shows a vague representation of the katamari's size, with an exact size goal (for Just Right stages)
@export var goal_type:GoalType = GoalType.SIZE
@export var end_at_120pts:bool = false
@export var skip_results:bool = false
@export var hide_ui:bool = false
@export_subgroup("Size Goal")
@export_range(0, 1, 0.01, "or_greater", "hide_slider", "suffix:m") var size_goal_minimum:float = 0
@export_range(0, 1, 0.01, "or_greater", "hide_slider", "suffix:m") var size_goal_100pts:float = 0
@export_range(0, 1, 0.01, "or_greater", "hide_slider", "suffix:m") var size_goal_120pts:float = 0
@export_subgroup("Point Goal")
@export_range(0, 1, 1, "or_greater", "hide_slider", "suffix:pt(s).") var point_goal_minimum:int = 0
@export_range(0, 1, 1, "or_greater", "hide_slider", "suffix:pt(s).") var point_goal_100pts:int = 0
@export_range(0, 1, 1, "or_greater", "hide_slider", "suffix:pt(s).") var point_goal_120pts:int = 0
@export var point_objects:Dictionary = {}
@export var point_name:Dictionary = {"en": ["{points} pts.", "{points} pt.", "{points} pts."]}
@export_subgroup("No Goal")
@export var none_show_object_count:bool = false
@export var none_can_quit_early:bool = false
@export_group("Time")
@export_range(-1, 1200, 1, "or_greater", "suffix:sec.") var time:float = 0
@export_range(-1, 1200, 1, "or_greater", "suffix:sec.") var time_100pts:float = 0
@export_range(-1, 1200, 1, "or_greater", "suffix:sec.") var time_120pts:float = 0

## Returns a JSON-compatible representation of this tree item and its children.
func to_json():
	var dict:Dictionary = {
		"name": mode_name,
		"music": {
			"default": default_music,
			"force_default": force_default_music
		},
		"pre_dialogue": pre_dialogue,
		"start_dialogue": start_dialogue,
		"retry_dialogue": retry_dialogue,
		"win_dialogue": win_dialogue,
		"fail_dialogue": fail_dialogue,
		"result_dialogue": result_dialogue,
		"katamari": {
			"size": katamari_size,
			"speed": katamari_speed,
			"can_dash": can_katamari_dash,
			"can_turn": can_katamari_turn,
			"can_dialogue_move": can_katamari_dialogue_move
		},
		"goal_type": int(goal_type),
		"end_at_120pts": end_at_120pts,
		"hide_ui": hide_ui,
		"goal_type_size": {
			"goal_minimum": size_goal_minimum,
			"goal_100pts": size_goal_100pts,
			"goal_120pts": size_goal_120pts
		},
		"goal_type_points": {
			"goal_minimum": point_goal_minimum,
			"goal_100pts": point_goal_100pts,
			"goal_120pts": point_goal_120pts,
			"point_objects": point_objects,
			"point_name": point_name
		},
		"goal_type_none":{
			"show_object_count": none_show_object_count,
			"can_quit_early": none_can_quit_early
		},
		"time": time,
		"time_100pts": time_100pts,
		"time_120pts": time_120pts,
		"skip_results": skip_results
	}
	var area_array:Array[Dictionary] = []
	var cam_array:Array[Dictionary] = []
	for child in get_children():
		if child is GKArea: area_array.push_back(child.to_json())
		if child is GKCamZone: cam_array.push_back(child.to_json())
	dict["map_zones"] = area_array
	dict["cam_zones"] = cam_array
	return dict

