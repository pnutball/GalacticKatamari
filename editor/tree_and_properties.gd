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
	"cam_zones": [],
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

const TemplateCamZone:Dictionary = {"Bound":0,"Scale":1.5,"Tilt":-15,"Shift":0.25,"DOF":20}

const TemplateSizeArea:Dictionary = {
							"advance_size": -1,
							"preload_size": -1,
							"scale": 1,
							"static": [],
							"objects": [],
							"spawn_positions": []
						}

const TemplateSpawn:Array = [0, 0, 0]

const TemplateObject:Dictionary = {"id":"debug_cube", "position":[0,0,0], "rotation":[0,0,0], "scale":1, "behavior":"static", "sub_objects":[], "unload_size":-1}

var lastSelectedLevel:TreeItem
var lastSelectedMode:TreeItem
var lastSelectedArea:TreeItem

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
	NewLevel.set_meta(&"type", "level")
	NewLevel.set_editable(0, true)
	NewLevel.set_text(0, "level_%d"%InternalLevelTree.size())
	InternalLevelTree[NewLevel.get_text(0)] = TemplateLevel.duplicate(true)
	NewLevel.set_meta(&"path", InternalLevelTree[NewLevel.get_text(0)])
	NewLevel.select(0)
	%Create/Mode.disabled = false
	output_print("Created new level.")
	addMode(NewLevel,true)

## Adds a mode to the tree. If set to auto, will autogenerate the name "normal"
func addMode(level:TreeItem, auto:bool = false):
	var NewMode:TreeItem = level.create_child()
	NewMode.set_icon(0, load("res://editor/icons/mode.png"))
	NewMode.set_meta(&"type", "mode")
	NewMode.set_editable(0, true)
	NewMode.set_text(0, "mode_%d"%InternalLevelTree[level.get_text(0)].modes.size() if not auto else "normal")
	InternalLevelTree[level.get_text(0)].modes[NewMode.get_text(0)] = TemplateMode.duplicate(true)
	NewMode.set_meta(&"path", level.get_meta(&"path").modes[NewMode.get_text(0)])
	NewMode.create_child().set_text(0, "Camera Areas")
	NewMode.create_child().set_text(0, "Size Areas")
	if not auto: NewMode.select(0) 
	else: 
		lastSelectedMode = NewMode
		lastSelectedLevel = level
	%Create/CamArea.disabled = false
	%Create/SizeArea.disabled = false
	output_print("Created new mode in level \"%s\"."%[level.get_text(0)])
	addCameraZone(NewMode)

## Adds a camera zone to the tree.
func addCameraZone(mode:TreeItem, auto:bool = false):
	var NewZone:TreeItem = mode.get_child(0).create_child()
	NewZone.set_icon(0, load("res://editor/icons/camerazone.png"))
	NewZone.set_meta(&"type", "cam_zone")
	NewZone.set_text(0, "Cam. Area %d" % NewZone.get_index())
	var zonesRoot:Array = lastSelectedMode.get_meta(&"path").cam_zones
	zonesRoot.push_back(TemplateCamZone.duplicate())
	NewZone.set_meta(&"path", zonesRoot[NewZone.get_index()])
	if not auto: NewZone.select(0)
	output_print("Created new cam. area in mode \"%s\"."%[mode.get_text(0)])

## Adds a size area to the tree.
func addSizeArea(mode:TreeItem, auto:bool = false):
	var NewZone:TreeItem = mode.get_child(1).create_child()
	NewZone.set_icon(0, load("res://editor/icons/area.png"))
	NewZone.set_meta(&"type", "area")
	NewZone.set_text(0, "Size Area %d" % NewZone.get_index())
	var zonesRoot:Array = lastSelectedMode.get_meta(&"path").map_zones
	zonesRoot.push_back(TemplateSizeArea.duplicate())
	NewZone.set_meta(&"path", zonesRoot[zonesRoot.size() - 1])
	if not auto: NewZone.select(0) 
	else: 
		lastSelectedArea = NewZone
		lastSelectedMode = mode
		lastSelectedLevel = mode.get_parent()
	NewZone.create_child().set_text(0, "Static")
	NewZone.create_child().set_text(0, "Objects")
	NewZone.create_child().set_text(0, "Spawnpoints")
	
	%Create/Spawn.disabled = false
	%Create/Static.disabled = false
	
	addSpawn(NewZone, true)
	
	# Add function call for creating a spawn point
	output_print("Created new size area in mode \"%s\"."%[mode.get_text(0)])

## Adds a static node to the tree.
func addStatic(area:TreeItem):
	var NewStatic:TreeItem = area.get_child(0).create_child()
	NewStatic.set_icon(0, load("res://editor/icons/static.png"))
	NewStatic.set_meta(&"type", "static")
	NewStatic.set_text(0, "Static %d" % NewStatic.get_index())
	var zonesRoot:Array = lastSelectedArea.get_meta(&"path").static
	zonesRoot.push_back("")
	NewStatic.set_meta(&"path", zonesRoot[zonesRoot.size() - 1])
	NewStatic.select(0)
	
	output_print("Created new static in area \"%d\"."%[area.get_index()])

## Adds an object to the tree.
func addObject(area:TreeItem, type:String = "debug_cube", position:Vector3 = Vector3.ZERO):
	var NewObject:TreeItem = area.get_child(1).create_child()
	NewObject.set_icon(0, load("res://editor/icons/object.png"))
	NewObject.set_meta(&"type", "object")
	NewObject.set_text(0, "Object %d" % NewObject.get_index())
	var zonesRoot:Array = lastSelectedArea.get_meta(&"path").objects
	zonesRoot.push_back(TemplateObject.duplicate(true))
	NewObject.set_meta(&"path", zonesRoot[zonesRoot.size() - 1])
	NewObject.get_meta(&"path").id = type
	NewObject.get_meta(&"path").position = [position.x, position.y, position.z]
	NewObject.select(0)
	
	output_print("Created a new %s in area \"%d\"."%[type, area.get_index()])

func addSpawn(area:TreeItem, auto:bool = false):
	var NewSpawn:TreeItem = area.get_child(2).create_child()
	NewSpawn.set_icon(0, load("res://editor/icons/spawn.png"))
	NewSpawn.set_meta(&"type", "spawn")
	NewSpawn.set_text(0, "Spawn %d" % NewSpawn.get_index())
	var zonesRoot:Array = lastSelectedArea.get_meta(&"path").spawn_positions
	zonesRoot.push_back(TemplateSpawn.duplicate())
	NewSpawn.set_meta(&"path", zonesRoot[zonesRoot.size() - 1])
	if not auto: NewSpawn.select(0)
	
	output_print("Created new spawn in area \"%d\"."%[area.get_index()])

func _on_properties_list_changed():
	if %PropertiesPanel:
		$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = %PropertiesPanel.get_child_count() == 0

func _on_create_id_pressed(id):
	match id:
		0: addLevel()
		1: addMode(lastSelectedLevel)
		2: addCameraZone(lastSelectedMode)
		3: addSizeArea(lastSelectedMode)
		4: addStatic(lastSelectedArea)
		5: addObject(lastSelectedArea)
		6: addSpawn(lastSelectedArea)

func _on_level_tree_item_selected():
	var item:TreeItem = %LevelTree.get_selected()
	if item.has_meta(&"type"):
		match item.get_meta(&"type", null):
			null:
				return
			"level": 
				lastSelectedLevel = item
			"mode": 
				lastSelectedMode = item
				lastSelectedLevel = item.get_parent()
			"area":
				lastSelectedArea = item
				lastSelectedMode = item.get_parent().get_parent()
				lastSelectedLevel = item.get_parent().get_parent().get_parent()
		
	

func output_print(printed:Variant):
	if printed as String != null:
		%Output.text += "\n" + printed as String
