extends VSplitContainer

signal ChangeMade

enum PropertyType{NUMBER, VECTOR3, STRING, DROPDOWN, BOOLEAN}

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
const DropdownProperty:PackedScene = preload("res://editor/property_drop.tscn")
const BooleanProperty:PackedScene = preload("res://editor/property_boolean.tscn")

func resetTree():
	for item in LevelTreeRoot.get_children():
		LevelTreeRoot.remove_child(item)
	LevelTreeRoot.set_text(0, "New File")
	for child in %PropertiesPanel.get_children():
		child.queue_free()
	$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = true
	%TreePanel/Create/Mode.disabled = true
	%TreePanel/Create/CamArea.disabled = true
	%TreePanel/Create/SizeArea.disabled = true
	%TreePanel/Create/Spawn.disabled = true
	%TreePanel/Create/Static.disabled = true
	InternalLevelTree = {}

func _ready():
	LevelTreeRoot.set_text(0, "New File")
	LevelTreeRoot.set_icon(0, load("res://editor/icons/document.png"))
	LevelTreeRoot.set_selectable(0, false)
	

## Adds a level to the tree.
func addLevel():
	var NewLevel:TreeItem = LevelTreeRoot.create_child()
	NewLevel.set_icon(0, load("res://editor/icons/level.png"))
	NewLevel.set_meta(&"type", "level")
	NewLevel.set_text(0, "level_%d"%InternalLevelTree.size())
	InternalLevelTree[NewLevel.get_text(0)] = TemplateLevel.duplicate(true)
	NewLevel.set_meta(&"path", InternalLevelTree[NewLevel.get_text(0)])
	NewLevel.select(0)
	%Create/Mode.disabled = false
	addMode(NewLevel,true)

## Adds a mode to the tree. If set to auto, will autogenerate the name "normal"
func addMode(level:TreeItem, auto:bool = false):
	var NewMode:TreeItem = level.create_child()
	NewMode.set_icon(0, load("res://editor/icons/mode.png"))
	NewMode.set_meta(&"type", "mode")
	NewMode.set_text(0, "mode_%d"%InternalLevelTree[level.get_text(0)].modes.size() if not auto else "normal")
	InternalLevelTree[level.get_text(0)].modes[NewMode.get_text(0)] = TemplateMode.duplicate(true)
	NewMode.set_meta(&"path", level.get_meta(&"path").modes[NewMode.get_text(0)])
	NewMode.create_child().set_text(0, "Camera Areas")
	NewMode.create_child().set_text(0, "Size Areas")
	for child in NewMode.get_children(): child.set_selectable(0,false)
	if not auto: NewMode.select(0) 
	else: lastSelectedMode = NewMode
	%Create/CamArea.disabled = false
	%Create/SizeArea.disabled = false
	addCameraZone(NewMode, true)
	addSizeArea(NewMode, true)

## Adds a camera zone to the tree.
func addCameraZone(mode:TreeItem, auto:bool = false):
	var NewZone:TreeItem = mode.get_child(0).create_child()
	NewZone.set_icon(0, load("res://editor/icons/camerazone.png"))
	NewZone.set_meta(&"type", "cam_zone")
	NewZone.set_text(0, "Cam. Area %d" % NewZone.get_index())
	var zonesRoot:Array = lastSelectedMode.get_meta(&"path").cam_zones
	zonesRoot.push_back(TemplateCamZone.duplicate(true))
	NewZone.set_meta(&"path", zonesRoot[NewZone.get_index()])
	if not auto: NewZone.select(0)

## Adds a size area to the tree.
func addSizeArea(mode:TreeItem, auto:bool = false):
	var NewZone:TreeItem = mode.get_child(1).create_child()
	NewZone.set_icon(0, load("res://editor/icons/area.png"))
	NewZone.set_meta(&"type", "area")
	NewZone.set_text(0, "Size Area %d" % NewZone.get_index())
	var zonesRoot:Array = lastSelectedMode.get_meta(&"path").map_zones
	zonesRoot.push_back(TemplateSizeArea.duplicate(true))
	NewZone.set_meta(&"path", zonesRoot[zonesRoot.size() - 1])
	if not auto: NewZone.select(0) 
	else: lastSelectedArea = NewZone
	NewZone.create_child().set_text(0, "Static")
	NewZone.create_child().set_text(0, "Objects")
	NewZone.create_child().set_text(0, "Spawnpoints")
	for child in NewZone.get_children(): child.set_selectable(0,false)
	
	%Create/Spawn.disabled = false
	%Create/Static.disabled = false
	
	addSpawn(NewZone, true)

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

## Adds an object to the tree.
func addObject(area:TreeItem, type:String = "debug_cube", obj_position:Vector3 = Vector3.ZERO):
	var NewObject:TreeItem = area.get_child(1).create_child()
	NewObject.set_icon(0, load("res://editor/icons/object.png"))
	NewObject.set_meta(&"type", "object")
	NewObject.set_text(0, "Object %d" % NewObject.get_index())
	var zonesRoot:Array = lastSelectedArea.get_meta(&"path").objects
	zonesRoot.push_back(TemplateObject.duplicate(true))
	NewObject.set_meta(&"path", zonesRoot[zonesRoot.size() - 1])
	NewObject.get_meta(&"path").id = type
	NewObject.get_meta(&"path").position = [obj_position.x, obj_position.y, obj_position.z]
	NewObject.select(0)

func addSpawn(area:TreeItem, auto:bool = false):
	var NewSpawn:TreeItem = area.get_child(2).create_child()
	NewSpawn.set_icon(0, load("res://editor/icons/spawn.png"))
	NewSpawn.set_meta(&"type", "spawn")
	NewSpawn.set_text(0, "Spawn %d" % NewSpawn.get_index())
	var zonesRoot:Array = lastSelectedArea.get_meta(&"path").spawn_positions
	zonesRoot.push_back(TemplateSpawn.duplicate(true))
	NewSpawn.set_meta(&"path", zonesRoot[zonesRoot.size() - 1])
	if not auto: NewSpawn.select(0)

func _on_create_id_pressed(id):
	ChangeMade.emit()
	match id:
		0: addLevel()
		1: addMode(lastSelectedLevel)
		2: addCameraZone(lastSelectedMode)
		3: addSizeArea(lastSelectedMode)
		4: addStatic(lastSelectedArea)
		5: addObject(lastSelectedArea)
		6: addSpawn(lastSelectedArea)

func _on_level_tree_item_selected():
	for child in %PropertiesPanel.get_children():
		child.queue_free()
	$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = true
	var item:TreeItem = %LevelTree.get_selected()
	if item.has_meta(&"type"):
		match item.get_meta(&"type"):
			"level": 
				lastSelectedLevel = item
				
				
			"mode": 
				lastSelectedMode = item
				lastSelectedLevel = item.get_parent()
				
				
			"area":
				lastSelectedArea = item
				lastSelectedMode = item.get_parent().get_parent()
				lastSelectedLevel = item.get_parent().get_parent().get_parent()
				
				
			"cam_zone":
				$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = false
				create_property(item, "Bound", PropertyType.NUMBER, "Lower Bound", "The size (meters) at which the camera goes to this camera area.")
				create_property(item, "Scale", PropertyType.NUMBER, "Scale", "The distance between the camera and katamari (in meters).")
				create_property(item, "Tilt", PropertyType.NUMBER, "Tilt", "The tilt of the camera (in degrees).")
				create_property(item, "Shift", PropertyType.NUMBER, "Vert. Shift", "The vertical shift of the camera.\nPositive values move the camera upwards.")
				create_property(item, "DOF", PropertyType.NUMBER, "DOF", "The depth-of-field distance (in meters).\n-1 disables DOF.")
			"static":
				pass
			"object":
				pass
			"spawn":
				pass
	
	

@warning_ignore("shadowed_variable_base_class")
func create_property(item:TreeItem, propertyPath:String, type:PropertyType, name:String = "Property", tooltip:String = "", dropdownItems:Array[String] = [""]):
	if not item.has_meta(&"path"): return ERR_INVALID_PARAMETER
	var PropertyNode:Control
	match type:
		PropertyType.NUMBER: PropertyNode = NumberProperty.instantiate()
		PropertyType.STRING: PropertyNode = StringProperty.instantiate()
		PropertyType.VECTOR3: PropertyNode = Vector3Property.instantiate()
		PropertyType.DROPDOWN: PropertyNode = DropdownProperty.instantiate()
		PropertyType.BOOLEAN: PropertyNode = BooleanProperty.instantiate()
	PropertyNode.P_Name = name
	PropertyNode.P_Tooltip = tooltip
	if type != PropertyType.VECTOR3:
		PropertyNode.P_Path = item.get_meta(&"path")
		PropertyNode.P_Property = propertyPath
	else:
		PropertyNode.P_Path = item.get_meta(&"path")[propertyPath]
	if type == PropertyType.DROPDOWN: PropertyNode.P_Items = dropdownItems
	PropertyNode.ChangeMade.connect(func(): ChangeMade.emit())
	%PropertiesPanel.add_child(PropertyNode)
