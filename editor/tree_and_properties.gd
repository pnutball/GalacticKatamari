extends VSplitContainer

signal ChangeMade

enum PropertyType{NUMBER, VECTOR3, STRING, DROPDOWN, BOOLEAN, LOCALIZED, DIALOGUE}

const TemplateLevel:Dictionary = {
	"name": {"en": "New level"},
	"description": {"en": "Enter a description here"},
	"modes": {}}

const TemplateMode:Dictionary = {
	"name": {"en": "New mode"},
	"music": {"default": "", "force_default": false},
	"pre_dialogue": {"en": "Put Our dialogue here..."},
	"start_dialogue": {"en": "Put Our dialogue here."},
	"retry_dialogue": {"en": "Put Our dialogue here."},
	"win_dialogue": {"en": "Put Our dialogue here!"},
	"fail_dialogue": {"en": "PUT OUR DIALOGUE HERE!!!"},
	"result_dialogue": {"en": "Put Our dialogue here."},
	"map_zones": [],
	"cam_zones": [],
	"katamari": {
		"size": 1,
		"speed": 4.5,
		"can_dash": true,
		"can_turn": true
	},
	"goal": {
		"type": "none",
		"goal": 0,
		"end_at_goal": false,
		"point_objects": "",
		"point_name": {
			"en": "pt{plural}."
		},
	},
	"time": 0,
	"ranking": {
		"skip_results": false,
		"size_super": -1,
		"time_super": -1,
		"point_super": -1
	}}

const TemplateCamZone:Dictionary = {"Bound":0,"Scale":1.5,"Tilt":-15,"Shift":0.25,"DOF":20}

const TemplateSizeArea:Dictionary = {
							"advance_size": -1,
							"preload_size": -1,
							"scale": 1,
							"warp_height": 0,
							"audio_size": "M",
							"core_model": "res://assets/models/core/core_generic.obj",
							"core_texture": "res://assets/textures/core/core_test.png",
							"time_bonus": 0,
							"static": [],
							"objects": [],
							"spawn_positions": []
						}

const TemplateSpawn:Array = [0, 0, 0, 0]

const TemplateObject:Dictionary = {"id":"debug_cube", "position":[0,0,0], "rotation":[0,0,0], "scale":1, "behavior":"static", "sub_objects":[], "unload_size":-1}

const TemplateObjDef:Dictionary = {
			"view_mesh": "res://assets/models/object/debug_cube_view.tres",
			"collision_mesh": "res://assets/models/object/debug_cube.shape",
			"knock_size": 0.6,
			"roll_size": 0.6,
			"pickup_size": 0.05,
			"scale": 1,
			"material": "",
			"material_rolledup": "",
			"name": {
				"en": "Debug Cube"
			},
			"description": {
				"en": "Dummy"
			},
			"bump_sound": "",
			"roll_sound": "",
			"animations": "",
			"approach_behavior": "",
			"collection_category": ""
		}

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
const LocalizedTextProperty:PackedScene = preload("res://editor/property_localized_text.tscn")
const DialogueProperty:PackedScene = preload("res://editor/property_dialogue.tscn")

func resetTree():
	for item in LevelTreeRoot.get_children():
		LevelTreeRoot.remove_child(item)
	LevelTreeRoot.set_text(0, "New File")
	for child in %PropertiesPanel.get_children():
		child.queue_free()
	$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = true
	%Create/Mode.disabled = true
	%Create/CamArea.disabled = true
	%Create/SizeArea.disabled = true
	%Create/Spawn.disabled = true
	%Create/Static.disabled = true
	%ObjectBrowser/InfoPanel/InfoPanelMargin/InfoPanelVbox/Object.disabled = true
	%PlayButton.disabled = true
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
	%PlayButton.disabled = false
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
	%ObjectBrowser/InfoPanel/InfoPanelMargin/InfoPanelVbox/Object.disabled = false
	
	addSpawn(NewZone, true)

## Adds a static node to the tree.
func addStatic(area:TreeItem):
	var NewStatic:TreeItem = area.get_child(0).create_child()
	NewStatic.set_icon(0, load("res://editor/icons/static.png"))
	NewStatic.set_meta(&"type", "static")
	NewStatic.set_text(0, "Static %d" % NewStatic.get_index())
	var zonesRoot:Array = lastSelectedArea.get_meta(&"path").static
	zonesRoot.push_back([""])
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
		5: addObject(lastSelectedArea, %ObjectBrowser/ObjectScroll/ObjectList.get_item_text(%ObjectBrowser/ObjectScroll/ObjectList.get_selected_items()[0]))
		6: addSpawn(lastSelectedArea)

func _on_level_tree_item_selected():
	for child in %PropertiesPanel.get_children():
		child.queue_free()
	$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = true
	var item:TreeItem = %LevelTree.get_selected()
	if item.has_meta(&"type"):
		match item.get_meta(&"type"):
			"level": 
				$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = false
				lastSelectedLevel = item
				create_property(item, "name", PropertyType.LOCALIZED, "Name", "The level's name.")
				create_property(item, "description", PropertyType.LOCALIZED, "Description", "The level's description.")
			"mode": 
				$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = false
				lastSelectedMode = item
				lastSelectedLevel = item.get_parent()
				# try adding a show/hide thing like you have with the localized strings
				
				create_property(item, "katamari/size", PropertyType.NUMBER, "Katamari Size", "The katamari's starting size, in meters.")
				create_property(item, "katamari/speed", PropertyType.NUMBER, "Katamari Speed", "The katamari's speed. 5 is the default.")
				create_property(item, "katamari/can_dash", PropertyType.BOOLEAN, "Katamari can Dash", "Can the katamari do the Dash?")
				create_property(item, "katamari/can_turn", PropertyType.BOOLEAN, "Katamari can Turn", "Can the katamari do the Quick Turn?")
				%PropertiesPanel.add_child(HSeparator.new())
				create_property(item, "time", PropertyType.NUMBER, "Time", "The amount of time given to complete the stage.\n0 disables the timer.\n-1 uses the Time Attack timer.")
				create_property(item, "ranking/time_super", PropertyType.NUMBER, "120 Time", "The target time for 120 pts.")
				create_property(item, "goal/type", PropertyType.DROPDOWN, "Goal Type", "The goal type for this stage.\nReachSize - Standard Make a Star size goal.\nExactSize - Exact Size goal.\nReachPoints - Roll up a certain amount of point objects.\nExactPoints - Roll up the exact # of point objects.", ["ReachSize", "ExactSize", "ReachPoints", "ExactPoints"])
				create_property(item, "goal/goal", PropertyType.NUMBER, "Goal", "The goal size/points for this stage.")
				create_property(item, "ranking/size_super", PropertyType.NUMBER, "120 Goal", "The target size for 120 pts.")
				create_property(item, "goal/end_at_goal", PropertyType.BOOLEAN, "End at Goal", "Does the stage immediately end when reaching the goal?")
				create_property(item, "goal/point_objects", PropertyType.STRING, "Point Objects", "The objects/categories that give points.\n$name denotes an object \"name\".\n&name denotes a category \"name\".")
				create_property(item, "goal/point_name", PropertyType.LOCALIZED, "Point Name", "The name used for points in the size indicator.\n{plural} is replaced with an 's' when the point count != 1.\n(e.g. \"point{plural}\" shows as either \"point\" or \"points\")")
				create_property(item, "ranking/point_super", PropertyType.NUMBER, "120 Point Goal", "The target point count for 120 pts.")
				%PropertiesPanel.add_child(HSeparator.new())
				# pre_dialogue DIALOGUE
				create_property(item, "pre_dialogue", PropertyType.DIALOGUE, "Pre-stage Dialogue", "The dialogue displayed before loading the stage.")
				# start_dialogue DIALOGUE
				create_property(item, "start_dialogue", PropertyType.DIALOGUE, "Start Dialogue", "The dialogue displayed before the timer starts.")
				# retry_dialogue DIALOGUE
				create_property(item, "retry_dialogue", PropertyType.DIALOGUE, "Retry Dialogue", "The dialogue displayed after retrying the stage without returning to Cosmea Town.")
				# win_dialogue DIALOGUE
				create_property(item, "win_dialogue", PropertyType.DIALOGUE, "Win Dialogue", "The dialogue displayed after winning.")
				# fail_dialogue DIALOGUE
				create_property(item, "fail_dialogue", PropertyType.DIALOGUE, "Fail Dialogue", "The dialogue displayed after failing.")
				# result_dialogue DIALOGUE
				create_property(item, "result_dialogue", PropertyType.DIALOGUE, "Results Dialogue", "The dialogue displayed on the results screen.")
			"area":
				$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = false
				lastSelectedArea = item
				lastSelectedMode = item.get_parent().get_parent()
				lastSelectedLevel = item.get_parent().get_parent().get_parent()
				create_property(item, "preload_size", PropertyType.NUMBER, "Preload Size", "The size at which the next area begins loading in the background.\n-1 disables preloading.")
				create_property(item, "advance_size", PropertyType.NUMBER, "Advance Size", "The size at which the katamari advances to the next area.\n-1 disables loading further areas.")
				create_property(item, "scale", PropertyType.NUMBER, "Map Scale", "The map's global scale.\nThis should be set so the average katamari size multiplied by scale = 1.")
				create_property(item, "warp_height", PropertyType.NUMBER, "Warp Height", "The height at which the Royal Warp is triggered.")
				# audio_size (Dropdown [XS, S, M, L, XL, C]
				create_property(item, "audio_size", PropertyType.DROPDOWN, "Size Audio", 
				"The set of sounds used when in this area. In order:\nXS - Extra small, eraser sized\nS - Small, people sized\nM - Medium, building sized\nL - Large, island sized\nXL - Extra large, country sized\nC - Cosmic, planet sized", ["XS", "S", "M", "L", "XL", "C"])
				# core_model
				create_property(item, "core_model", PropertyType.STRING, "Katamari Model", "The model used by the katamari in this size area.")
				# core_texture
				create_property(item, "core_texture", PropertyType.STRING, "Katamari Texture", "The texture used by the katamari in this size area.")
				# time_bonus
				create_property(item, "time_bonus", PropertyType.NUMBER, "Time Bonus", "The amount of time added when entering this area.")
			"cam_zone":
				$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = false
				create_property(item, "Bound", PropertyType.NUMBER, "Lower Bound", "The size (meters) at which the camera goes to this camera area.")
				create_property(item, "Scale", PropertyType.NUMBER, "Scale", "The distance between the camera and katamari (in meters).")
				create_property(item, "Tilt", PropertyType.NUMBER, "Tilt", "The tilt of the camera (in degrees).")
				create_property(item, "Shift", PropertyType.NUMBER, "Vert. Shift", "The vertical shift of the camera.\nPositive values move the camera upwards.")
				create_property(item, "DOF", PropertyType.NUMBER, "DOF", "The depth-of-field distance (in meters).\n-1 disables DOF.")
			"static":
				$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = false
				create_property(item, "0", PropertyType.STRING, "File Path", "The path to the resource (.tscn) used by this Static.")
			"object":
				$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = false
				create_property(item, "id", PropertyType.STRING, "Object Type", "The object ID used by this object.")
				create_property(item, "position", PropertyType.VECTOR3, "Position", "The object's position.")
				create_property(item, "rotation", PropertyType.VECTOR3, "Rotation", "The object's rotation (in degrees).")
				create_property(item, "behavior", PropertyType.DROPDOWN, "Behavior", "The object's behavior.", ["static", "physics", "path", "roam"])
				create_property(item, "unload_size", PropertyType.NUMBER, "Unload Size", "The size, in meters, at which the object permanently despawns.")
			"spawn":
				$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = false
				create_property(item, "", PropertyType.VECTOR3, "Position", "The spawn position, relative to the bottom of the katamari.")
				create_property(item, "3", PropertyType.NUMBER, "Scale", "The camera rotation used when the katamari is spawned here (in degrees).")

func openDict(dict:Dictionary):
	resetTree()
	lastSelectedLevel = null
	lastSelectedMode = null
	lastSelectedArea = null
	InternalLevelTree = dict.duplicate()
	for levelKey in InternalLevelTree.keys():
		#region Level TreeItem init
		var NewLevel:TreeItem = LevelTreeRoot.create_child()
		NewLevel.set_icon(0, load("res://editor/icons/level.png"))
		NewLevel.set_meta(&"type", "level")
		NewLevel.set_text(0, levelKey)
		NewLevel.set_meta(&"path", InternalLevelTree[levelKey])
		if lastSelectedLevel == null: lastSelectedLevel = NewLevel
		#endregion
		%Create/Mode.disabled = false
		for modeKey in InternalLevelTree[levelKey].modes.keys():
			#region Mode TreeItem init
			var NewMode:TreeItem = NewLevel.create_child()
			NewMode.set_icon(0, load("res://editor/icons/mode.png"))
			NewMode.set_meta(&"type", "mode")
			NewMode.set_text(0, modeKey)
			NewMode.set_meta(&"path", InternalLevelTree[levelKey].modes[modeKey])
			NewMode.create_child().set_text(0, "Camera Areas")
			NewMode.create_child().set_text(0, "Size Areas")
			for child in NewMode.get_children(): child.set_selectable(0,false)
			if lastSelectedMode == null: lastSelectedMode = NewMode
			#endregion
			%PlayButton.disabled = false
			%Create/CamArea.disabled = false
			%Create/SizeArea.disabled = false
			
			for camIndex in InternalLevelTree[levelKey].modes[modeKey].cam_zones.size():
				#region Cam Area TreeItem init
				var NewZone:TreeItem = NewMode.get_child(0).create_child()
				NewZone.set_icon(0, load("res://editor/icons/camerazone.png"))
				NewZone.set_meta(&"type", "cam_zone")
				NewZone.set_text(0, "Cam. Area %d" % camIndex)
				NewZone.set_meta(&"path", InternalLevelTree[levelKey].modes[modeKey].cam_zones[camIndex])
				#endregion
			
			for areaIndex in InternalLevelTree[levelKey].modes[modeKey].map_zones.size():
				#region Sizw Area TreeItem init
				var NewZone:TreeItem = NewMode.get_child(1).create_child()
				NewZone.set_icon(0, load("res://editor/icons/area.png"))
				NewZone.set_meta(&"type", "area")
				NewZone.set_text(0, "Size Area %d" % areaIndex)
				NewZone.set_meta(&"path", InternalLevelTree[levelKey].modes[modeKey].map_zones[areaIndex])
				NewZone.create_child().set_text(0, "Static")
				NewZone.create_child().set_text(0, "Objects")
				NewZone.create_child().set_text(0, "Spawnpoints")
				for child in NewZone.get_children(): child.set_selectable(0,false)
				if lastSelectedArea == null: lastSelectedArea = NewZone
				#endregion
				%Create/Spawn.disabled = false
				%Create/Static.disabled = false
				%ObjectBrowser/InfoPanel/InfoPanelMargin/InfoPanelVbox/Object.disabled = false
				
				for staticIndex in InternalLevelTree[levelKey].modes[modeKey].map_zones[areaIndex].static.size():
					var NewStatic:TreeItem = NewZone.get_child(0).create_child()
					NewStatic.set_icon(0, load("res://editor/icons/static.png"))
					NewStatic.set_meta(&"type", "static")
					NewStatic.set_text(0, "Static %d" % staticIndex)
					NewStatic.set_meta(&"path", InternalLevelTree[levelKey].modes[modeKey].map_zones[areaIndex].static[staticIndex])
				
				for objectIndex in InternalLevelTree[levelKey].modes[modeKey].map_zones[areaIndex].objects.size():
					var NewObject:TreeItem = NewZone.get_child(1).create_child()
					NewObject.set_icon(0, load("res://editor/icons/object.png"))
					NewObject.set_meta(&"type", "object")
					NewObject.set_text(0, "Object %d" % objectIndex)
					NewObject.set_meta(&"path", InternalLevelTree[levelKey].modes[modeKey].map_zones[areaIndex].objects[objectIndex])
				
				for spawnIndex in InternalLevelTree[levelKey].modes[modeKey].map_zones[areaIndex].spawn_positions.size():
					var NewSpawn:TreeItem = NewZone.get_child(2).create_child()
					NewSpawn.set_icon(0, load("res://editor/icons/spawn.png"))
					NewSpawn.set_meta(&"type", "spawn")
					NewSpawn.set_text(0, "Spawn %d" % spawnIndex)
					NewSpawn.set_meta(&"path", InternalLevelTree[levelKey].modes[modeKey].map_zones[areaIndex].spawn_positions[spawnIndex])

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
		PropertyType.LOCALIZED: PropertyNode = LocalizedTextProperty.instantiate()
		PropertyType.DIALOGUE: PropertyNode = DialogueProperty.instantiate()
	PropertyNode.P_Name = name
	PropertyNode.P_Tooltip = tooltip
	if type != PropertyType.VECTOR3:
		PropertyNode.P_Path = item.get_meta(&"path")
		PropertyNode.P_Property = propertyPath
	else:
		if propertyPath == "": PropertyNode.P_Path = item.get_meta(&"path") 
		else: PropertyNode.P_Path = item.get_meta(&"path")[propertyPath]
		
	if type == PropertyType.DROPDOWN: PropertyNode.P_Items = dropdownItems
	PropertyNode.ChangeMade.connect(emitChange)
	%PropertiesPanel.add_child(PropertyNode)

func emitChange(): ChangeMade.emit()
