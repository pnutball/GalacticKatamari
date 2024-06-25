extends Control

enum GoalType {NONE, SIZE, POINTS, EXACT_SIZE}

@onready var mode = StageLoader.currentStage.modes.get(StageLoader.currentMode)
@onready var goal_type:GoalType = int(mode["goal_type"]) as GoalType

const UI_SIZE_MIN = 0.4
const UI_SIZE_MAX = 1
const UI_SIZE_SUPER = 1.15
const SIZE_COUNTER_LENGTH: Array[int] = [0, 3, 2, 1, 0]
const SIZE_COUNTER_SUFFIX: Array[String] = ["km", "m", "cm", "mm"]

var ui_min:float = 1
var ui_current:float = 1
var ui_max:float = 1
var ui_super:float = 1

var size_label:RichTextLabel = null
var size_font_size_change:bool = true

var point_label:RichTextLabel = null
var point_font_size_change:bool = false

func _ready():
	if goal_type != GoalType.EXACT_SIZE and goal_type != GoalType.POINTS:
		ui_min = mode["katamari"]["size"]
		ui_max = mode["goal_type_size"]["goal_minimum"]
		ui_super = mode["goal_type_size"]["goal_100pts"]
		size_label = $OffsetBase/MainCounter
		point_label = $OffsetBase/SubCounter
		if mode.get("goal_type_points", {}).get("point_objects", {}) == {}:
			$OffsetBase/SubCounter.visible = false
		
		var after_first_chunk:bool = false
		var chunk_no:int = 0
		var size_array:Array[int] = [floori(ui_max / 1000), 
		floori(ui_max) % 1000, 
		floori(ui_max * 100) % 100, 
		floori(ui_max * 1000) % 10]
		var size_string:String = ""
		for chunk:int in size_array.size():
			if size_array[chunk] > 0 or after_first_chunk:
				after_first_chunk = true
				var suffix_chunk = SIZE_COUNTER_SUFFIX[chunk]
				if chunk_no > 0: size_string += "%0*d%s" % [SIZE_COUNTER_LENGTH[chunk], size_array[chunk], suffix_chunk]
				else: size_string += "%d%s" % [size_array[chunk], suffix_chunk]
				chunk_no += 1
		$OffsetBase/GoalCounter.text = size_string
	elif goal_type == GoalType.POINTS:
		ui_min = 0
		ui_max = mode["goal_type_points"]["goal_minimum"]
		ui_super = mode["goal_type_points"]["goal_100pts"]
		point_label = $OffsetBase/MainCounter
		size_label = $OffsetBase/SubCounter
		size_font_size_change = false
		point_font_size_change = true
		
		var point_string:String = ""
		var count:String = str(ui_max)
		point_string += GKGlobal.get_localized_plural(int(ui_max), mode["goal_type_points"]["point_name"])
		$OffsetBase/GoalCounter.text = point_string.format({"points": count})
	if goal_type == GoalType.NONE:
		$OffsetBase/GoalCounter.visible = false
		$OffsetBase/Arrow.visible = false

func _process(delta):
	# Meter size
	if goal_type == GoalType.POINTS: ui_current = get_parent().Score
	else: ui_current = get_parent().Size
	$OffsetBase/MeterShapes/MeterShape1.rotation += delta * (PI/8)
	$OffsetBase/MeterShapes/MeterShape2.rotation -= delta * (PI/7.5)
	$OffsetBase/MeterShapes/MeterShape3.rotation += delta * (PI/6)
	var scalef = (lerpf(UI_SIZE_MIN, UI_SIZE_MAX, clampf((ui_current - ui_min)/(ui_max - ui_min), 0, 1))
	if ui_current < ui_max or ui_super <= ui_max else lerpf(UI_SIZE_MAX, UI_SIZE_SUPER, clampf((ui_current - ui_max)/(ui_super - ui_max), 0, 1)))
	$OffsetBase/MeterShapes.scale = Vector2(scalef, scalef)
	# Size label
	if size_label.visible:
		var after_first_chunk:bool = false
		var chunk_no:int = 0
		var size_array:Array[int] = [floori(get_parent().Size / 1000), 
		floori(get_parent().Size) % 1000, 
		floori(get_parent().Size * 100) % 100, 
		floori(get_parent().Size * 1000) % 10]
		var size_string:String = ""
		for chunk:int in size_array.size():
			if size_array[chunk] > 0 or after_first_chunk:
				after_first_chunk = true
				if size_font_size_change: 
					size_string += "[font_size=%d]" % (90-(10*chunk_no))
				var suffix_chunk = ("[font_size=50]" if size_font_size_change else "") + SIZE_COUNTER_SUFFIX[chunk]
				if chunk_no > 0: size_string += "%0*d%s" % [SIZE_COUNTER_LENGTH[chunk], size_array[chunk], suffix_chunk]
				else: size_string += "%d%s" % [size_array[chunk], suffix_chunk]
				chunk_no += 1
		size_label.text = size_string
	# Point label
	if point_label.visible:
		var point_string:String = ""
		var count:String = str(get_parent().Score)
		if point_font_size_change:
			point_string += "[font_size=90]"
			count = "[font_size=90]" + count + "[font_size=50]"
		point_string += GKGlobal.get_localized_plural(get_parent().Score, mode["goal_type_points"]["point_name"])
		point_label.text = point_string.format({"points": count})
