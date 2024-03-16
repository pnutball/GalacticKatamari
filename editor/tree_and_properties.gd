extends VSplitContainer

const TemplateLevel:Dictionary = {
	"name": {"en": "New level"},
	"description": {"en": "Enter a description here"},
	"modes": {}}

const TemplateMode:Dictionary = {
	"name": {"en": "New mode"},
	"music": {"default": "", "force_default": false},
	"pre_dialogue": {"en": ["Put Our dialogue here..."]},
	"start_dialogue": {"en": ["Put Our dialogue here."]},
	"retry_dialogue": {"en": ["Put Our dialogue here."]},
	"end_dialogue": {"en": ["Put Our dialogue here!"]},
	"fail_dialogue": {"en": ["PUT OUR DIALOGUE HERE!!!"]},
	"post_dialogue": {"en": ["Put Our dialogue here."]},
	"map_zones": [],
	"cam_zones": [
		{"Bound":0,"Scale":1.5,"Tilt":-15,"Shift":0.25,"DOF":20}
	],
	"katamari": {
		"size": 1,
		"model": "res://models/core/core_generic.obj",
		"texture": "res://textures/core/core_test.png",
		"start_positions": [[0, 0.3, 0]],
		"speed": 5,
		"can_dash": true,
		"can_turn": true,
		"cam_rotation": 0
	},
	"goal_type": "none",
	"goal": 0,
	"time": 0
	}

var lastSelectedLevel:TreeItem
var lastSelectedMode:TreeItem

@onready var LevelTreeRoot:TreeItem = %LevelTree.create_item()
var InternalLevelTree:Dictionary = {}

const Vector3Property:PackedScene = preload("res://editor/property_vector3.tscn")
const NumberProperty:PackedScene = preload("res://editor/property_number.tscn")
const StringProperty:PackedScene = preload("res://editor/property_string.tscn")

func _ready():
	LevelTreeRoot.set_text(0, "New File")
	LevelTreeRoot.set_icon(0, load("res://editor/icons/document.png"))

## Adds a level to the tree.
func addLevel():
	var NewLevel:TreeItem = LevelTreeRoot.create_child()
	NewLevel.set_icon(0, load("res://editor/icons/level.png"))
	NewLevel.set_editable(0, true)
	NewLevel.set_text(0, "level_%d"%InternalLevelTree.size())
	InternalLevelTree[NewLevel.get_text(0)] = TemplateLevel.duplicate(true)
	addMode(NewLevel,true)
	NewLevel.select(0)
	%Create.set_item_disabled(1, false)

## Adds a mode to the tree. If set to auto, will autogenerate the name "normal"
func addMode(level:TreeItem, auto:bool = false):
	var NewMode:TreeItem = level.create_child()
	NewMode.set_icon(0, load("res://editor/icons/mode.png"))
	NewMode.set_editable(0, true)
	NewMode.set_text(0, "mode_%d"%InternalLevelTree[level.get_text(0)].modes.size() if not auto else "normal")
	InternalLevelTree[level.get_text(0)].modes[NewMode.get_text(0)] = TemplateMode.duplicate(true)
	if auto: NewMode.select(0)
	else: lastSelectedMode = NewMode
	%Create.set_item_disabled(2, false)

func _on_properties_list_changed():
	if %PropertiesPanel:
		$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = %PropertiesPanel.get_child_count() == 0

func _on_create_id_pressed(id):
	match id:
		0: addLevel()
		1: addMode(lastSelectedLevel)

func _on_level_tree_item_selected():
	var item:TreeItem = %LevelTree.get_selected()
	match item.get_icon(0):
		preload("res://editor/icons/level.png"): lastSelectedLevel = item
		preload("res://editor/icons/mode.png"): lastSelectedMode = item
