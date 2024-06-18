@icon("res://editor/class_icons/GKEditorTreeMode.svg")
class_name GKEditorTreeMode
extends GKEditorTreeItem

enum GoalType {NONE, SIZE, POINTS, EXACT_SIZE}

## The mode's ID, ex. "normal", "eternal", "drive", etc.
@export var mode_id:String = "normal"
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
@export var point_name:Dictionary = {"en": "{points}pt{plural}."}
@export_subgroup("No Goal")
@export var none_show_object_count:bool = false
@export var none_can_quit_early:bool = false
@export_group("Time")
@export_range(-1, 1200, 1, "or_greater", "suffix:sec.") var time:float = 0
@export_range(-1, 1200, 1, "or_greater", "suffix:sec.") var time_100pts:float = 0
@export_range(-1, 1200, 1, "or_greater", "suffix:sec.") var time_120pts:float = 0
## Returns a JSON-compatible representation of this tree item and its children.
func to_json() -> Dictionary:
	var dict:Dictionary = {
		"name": {
			"en": mode_name
		},
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
	for child in children:
		if child is GKEditorTreeArea: area_array.push_back(child.to_json())
		if child is GKEditorTreeCamZone: cam_array.push_back(child.to_json())
	dict["map_zones"] = area_array
	dict["cam_zones"] = cam_array
	return dict

## Creates a this tree item and its children from a source Dictionary.
static func from_json(from:Dictionary, name:String = "") -> GKEditorTreeMode:
	var new_mode:GKEditorTreeMode = GKEditorTreeMode.new()
	new_mode.mode_id = name
	new_mode.mode_name = from.get("name", new_mode.mode_name)
	
	new_mode.default_music = from.get("music", {}).get("default", new_mode.default_music)
	new_mode.force_default_music = from.get("music", {}).get("force_default", new_mode.force_default_music)
	
	new_mode.pre_dialogue = from.get("pre_dialogue", new_mode.pre_dialogue)
	new_mode.start_dialogue = from.get("start_dialogue", new_mode.start_dialogue)
	new_mode.retry_dialogue = from.get("retry_dialogue", new_mode.retry_dialogue)
	new_mode.win_dialogue = from.get("win_dialogue", new_mode.win_dialogue)
	new_mode.fail_dialogue = from.get("fail_dialogue", new_mode.fail_dialogue)
	new_mode.result_dialogue = from.get("result_dialogue", new_mode.result_dialogue)
	
	new_mode.katamari_size = from.get("katamari", {}).get("size", new_mode.katamari_size)
	new_mode.katamari_speed = from.get("katamari", {}).get("speed", new_mode.katamari_speed)
	new_mode.can_katamari_dash = from.get("katamari", {}).get("can_dash", new_mode.can_katamari_dash)
	new_mode.can_katamari_turn = from.get("katamari", {}).get("can_turn", new_mode.can_katamari_turn)
	new_mode.can_katamari_dialogue_move = from.get("katamari", {}).get("can_dialogue_move", new_mode.can_katamari_dialogue_move)
	
	new_mode.goal_type = from.get("goal_type", new_mode.goal_type)
	new_mode.end_at_120pts = from.get("end_at_120pts", new_mode.end_at_120pts)
	new_mode.hide_ui = from.get("hide_ui", new_mode.hide_ui)
	new_mode.skip_results = from.get("skip_results", new_mode.skip_results)
	
	new_mode.size_goal_minimum = from.get("goal_type_size", {}).get("goal_minimum", new_mode.size_goal_minimum)
	new_mode.size_goal_100pts = from.get("goal_type_size", {}).get("goal_100pts", new_mode.size_goal_100pts)
	new_mode.size_goal_120pts = from.get("goal_type_size", {}).get("goal_120pts", new_mode.size_goal_120pts)
	
	new_mode.point_goal_minimum = from.get("goal_type_points", {}).get("goal_minimum", new_mode.point_goal_minimum)
	new_mode.point_goal_100pts = from.get("goal_type_points", {}).get("goal_100pts", new_mode.point_goal_100pts)
	new_mode.point_goal_120pts = from.get("goal_type_points", {}).get("goal_120pts", new_mode.point_goal_120pts)
	new_mode.point_objects = from.get("goal_type_points", {}).get("point_objects", new_mode.point_objects)
	new_mode.point_name = from.get("goal_type_points", {}).get("point_name", new_mode.point_name)
	
	new_mode.none_show_object_count = from.get("goal_type_none", {}).get("show_object_count", new_mode.none_show_object_count)
	new_mode.none_can_quit_early = from.get("goal_type_none", {}).get("can_quit_early", new_mode.none_can_quit_early)
	
	new_mode.time = from.get("time", new_mode.time)
	new_mode.time_100pts = from.get("time_100pts", new_mode.time_100pts)
	new_mode.time_120pts = from.get("time_120pts", new_mode.time_120pts)
	
	for key in from.get("map_zones", {}).keys():
		new_mode.add_child(GKEditorTreeArea.from_json(from.get("map_zones", {})[key], key))
	
	for key in from.get("cam_zones", {}).keys():
		new_mode.add_child(GKEditorTreeCamZone.from_json(from.get("cam_zones", {})[key], key))
	
	return new_mode

## Creates property packed scenes for this node.
func send_properties(to:BoxContainer) -> void:
	super(to)
	_create_property(to, PropertyType.STRING, &"mode_id", "", "")
	_create_property(to, PropertyType.LOCALIZED, &"mode_name", "", "")
	var group_music = _create_property_group(to, "Music")
	_create_property(group_music, PropertyType.STRING, &"default_music", "Default Music", "The mode's default music.\nIf blank or invalid, defaults to silence.")
	_create_property(group_music, PropertyType.BOOLEAN, &"force_default_music", "Force Default Music", "If true, forces the default music to be played even if the level's been played before.")
	var group_dialogue = _create_property_group(to, "Dialogue")
	_create_property(group_dialogue, PropertyType.DIALOGUE, &"pre_dialogue", "Pre-Stage Dialogue", "The dialogue spoken before the stage loads.")
	_create_property(group_dialogue, PropertyType.DIALOGUE, &"start_dialogue", "Start Dialogue", "The dialogue spoken before the stage begins.")
	_create_property(group_dialogue, PropertyType.DIALOGUE, &"retry_dialogue", "Retry Dialogue", "The dialogue spoken after retrying the stage.")
	_create_property(group_dialogue, PropertyType.DIALOGUE, &"win_dialogue", "Win Dialogue", "The dialogue spoken after winning the stage.")
	_create_property(group_dialogue, PropertyType.DIALOGUE, &"fail_dialogue", "Fail Dialogue", "The dialogue spoken after failing the stage.")
	_create_property(group_dialogue, PropertyType.DIALOGUE, &"result_dialogue", "Result Dialogue", "The dialogue spoken during the result screen.")
	var group_katamari = _create_property_group(to, "Katamari")
	_create_property(group_katamari, PropertyType.NUMBER, &"katamari_size", "Size", "The initial size of the katamari.")
	_create_property(group_katamari, PropertyType.NUMBER, &"katamari_speed", "Speed", "The katamari's speed.\nFor most stages, this should be 4.5.\nFor Drive Mode, this should be double the usual speed (usually 9)")
	_create_property(group_katamari, PropertyType.BOOLEAN, &"can_katamari_dash", "Can Dash?", "If true, the katamari can use the Dash.")
	_create_property(group_katamari, PropertyType.BOOLEAN, &"can_katamari_dash", "Can Quick Turn?", "If true, the katamari can use the Quick Turn.")
	_create_property(group_katamari, PropertyType.BOOLEAN, &"can_katamari_dash", "Can Move During Dialogue?", "If true, the katamari can move while the King is speaking before the stage begins.")
	var group_time = _create_property_group(to, "Time")
	_create_property(group_time, PropertyType.NUMBER, &"time", "Time Limit", "The amount of time the player has, in seconds.\nIf set to less than 0, uses the Time Attack timer (counts up and saves best time).\nIf set to 0, disables the timer entirely.")
	_create_property(group_time, PropertyType.NUMBER, &"time_100_pts", "100pts. Time", "The maximum elapsed time required for a 100pt score.\nDoes nothing if not using the Time Attack timer.")
	_create_property(group_time, PropertyType.NUMBER, &"time_120_pts", "120pts. Time", "The maximum elapsed time required for a 120pt score.\nIf using the normal timer, determines the time required to get a Meteor.")
	var group_goals = _create_property_group(to, "Goals")
	_create_dropdown_property(group_goals, ["None", "Size", "Points", "Exact Size"], &"goal_type", "Goal Type", "The mode's goal type.\nNone: Shows the katamari's size, without setting a goal. (for Eternal or demo stages)\nSize: Sets a size goal. If there are point objects, factors points into scoring. (for Roll it Big)\nPoints: Scores based on points, while also showing size. (for gimmick stages)\nExact Size: Scores based on how close you are to a goal size. (for Just Right)")
	_create_property(group_goals, PropertyType.BOOLEAN, &"end_at_120_pts", "End at 120pts?", "If true, ends the stage immediately when getting 120pts for the primary goal.")
	_create_property(group_goals, PropertyType.BOOLEAN, &"skip_results", "Skip Results?", "If true, skips the stage results and returns directly to Cosmea Town.")
	_create_property(group_goals, PropertyType.BOOLEAN, &"hide_ui", "Hide UI?", "If true, hides the UI (except pause menu & King).")
	var group_size = _create_property_group(group_goals, "Size Goal")
	_create_property(group_size, PropertyType.NUMBER, &"size_goal_minimum", "Goal Size", "The goal size, in meters.\nIn Exact Size, this is the exact size.")
	_create_property(group_size, PropertyType.NUMBER, &"size_goal_100_pts", "100pts. Goal", "The required size for a 100pt score.\nIn Exact Size, this is a margin of error (within 1-10cm)")
	_create_property(group_size, PropertyType.NUMBER, &"size_goal_120_pts", "120pts. Goal", "The required size for a 120pt score.\nIn Exact Size, this is the minimum acceptable size.")
	var group_point = _create_property_group(group_goals, "Point Goal")
	_create_property(group_point, PropertyType.NUMBER, &"point_goal_minimum", "Goal Points", "The goal amount of points.")
	_create_property(group_point, PropertyType.NUMBER, &"point_goal_100_pts", "100pts. Goal", "The required points for a 100pt score.")
	_create_property(group_point, PropertyType.NUMBER, &"point_goal_120_pts", "120pts. Goal", "The required points for a 120pt score.")
	_create_property(group_point, PropertyType.DICTIONARY, &"point_objects", "Point Objects", "A list of objects or categories that give points.\nCategories are denoted by a \'$\' before the name.")
	_create_property(group_point, PropertyType.LOCALIZED, &"point_name", "Point Name", "The localized name of the points.\n{points} is the amount of points.\n{plural} is the string used to denote plurality (if necessary).")
	var group_none = _create_property_group(group_goals, "No Goal")
	_create_property(group_none, PropertyType.BOOLEAN, &"none_show_object_count", "Show Object Count?", "If true, shows object count.")
	_create_property(group_none, PropertyType.BOOLEAN, &"none_can_quit_early", "Can Quit Early?", "If true, lets the player quit early after rolling up one object.")
	return
