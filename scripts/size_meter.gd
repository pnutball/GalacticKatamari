extends Control

enum GoalType {NONE, SIZE, POINTS, EXACT_SIZE}

@onready var mode = StageLoader.currentStage.modes.get(StageLoader.currentMode)
@onready var goal_type:GoalType = int(mode["goal_type"]) as GoalType

const UI_SIZE_MIN = 0.4
const UI_SIZE_MAX = 1
const SIZE_COUNTER_LENGTH: Array[int] = [0, 3, 2, 1, 0]
const SIZE_COUNTER_SUFFIX: Array[String] = ["km", "m", "cm", "mm"]

var ui_min:float = 1
var ui_current:float = 1
var ui_max:float = 1

var size_label:RichTextLabel = null
var size_font_size_change:bool = true

func _ready():
	if goal_type != GoalType.EXACT_SIZE and goal_type != GoalType.POINTS:
		ui_min = mode["katamari"]["size"]
		ui_max = mode["goal_type_size"]["goal_minimum"]
		size_label = $OffsetBase/MainCounter
		
	elif goal_type == GoalType.POINTS:
		ui_min = 0
		ui_max = mode["goal_type_points"]["goal_minimum"]
		size_font_size_change = false

func _process(delta):
	# Meter size
	if goal_type == GoalType.POINTS: pass
	else: ui_current = get_parent().Size
	$OffsetBase/MeterShapes/MeterShape1.rotation += delta * (PI/8)
	$OffsetBase/MeterShapes/MeterShape2.rotation -= delta * (PI/7.5)
	$OffsetBase/MeterShapes/MeterShape3.rotation += delta * (PI/6)
	var scalef = lerpf(UI_SIZE_MIN, UI_SIZE_MAX, clampf((ui_current - ui_min)/(ui_max - ui_min), 0, 1))
	$OffsetBase/MeterShapes.scale = Vector2(scalef, scalef)
	# Size label
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
				size_string += "[font_size=%d]" % (100-(10*chunk_no))
			if chunk_no > 0: size_string += "%0*d%s" % [SIZE_COUNTER_LENGTH[chunk], size_array[chunk], SIZE_COUNTER_SUFFIX[chunk]]
			else: size_string += "%d%s" % [size_array[chunk], SIZE_COUNTER_SUFFIX[chunk]]
			chunk_no += 1
	size_label.text = size_string
