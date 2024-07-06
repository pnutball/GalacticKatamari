extends Node

signal stage_loaded
signal stage_instantiated

var objectList:Dictionary = load("res://data/objects.json").data["objects"]
var currentStage:Dictionary
var currentMode:String
var currentArea:int = 0
var stageRoot:Node3D
var preloadRoot:Node3D = Node3D.new()
var currentKatamari
var loadFinished:bool = true
var restarted:bool = false

const RollableObject:PackedScene = preload("res://scenes/game/object/rollable_object_3d.tscn")
const KatamariControllable:PackedScene = preload("res://scenes/game/object/katamari_controllable.tscn")
const TimerNormal:PackedScene = preload("res://scenes/ui/timer_normal.tscn")

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready():
	preloadRoot.process_mode = Node.PROCESS_MODE_DISABLED

## Returns an array of stage names located in the file at path, or an Error.
func getStages(path:String):
	if not path.ends_with(".gkl.json"):
		return ERR_FILE_BAD_PATH
	ResourceLoader.load_threaded_request(path)
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().create_timer(0.1).timeout
	if ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_LOADED:
		return ERR_FILE_CANT_OPEN
	else:
		var json = ResourceLoader.load_threaded_get(path)
		if "levels" in json.data:
			return json.data.levels.keys()
		else:
			return ERR_FILE_CANT_READ

## Loads a stage's JSON data into currentStage.
##
## path: The path to the .gkl.json file containing the level.
## stage_name: The level's internal name.
func loadStage(path:String, stage_name:String):
	if not path.ends_with(".gkl.json"):
		return ERR_FILE_BAD_PATH
	ResourceLoader.load_threaded_request(path)
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().create_timer(0.1).timeout
	if ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_LOADED:
		return ERR_FILE_CANT_OPEN
	else:
		var json = ResourceLoader.load_threaded_get(path)
		if "levels" in json.data and stage_name in json.data.levels:
			currentStage = json.data.levels.get(stage_name)
		else:
			return ERR_FILE_CANT_READ
	
	stage_loaded.emit()
	return OK

func loadStagefromDict(dict:Dictionary, stage_name:String):
	if "levels" in dict and stage_name in dict.levels:
			currentStage = dict.levels.get(stage_name)
	else: return ERR_INVALID_PARAMETER
	stage_loaded.emit()
	return OK
	

## Get the currently loaded stage's modes.
func getModes():
	return currentStage.modes.keys()

## Instantiates the currently loaded stage.
##
## mode: The level's mode.
## parent: The node that the stage root node is parented to.
func instantiateStage(mode:String, parent:Node = get_tree().get_root()):
	GKOverlays.load_start()
	currentMode = mode
	stageRoot = Node3D.new()
	stageRoot.name = "KatamariStageRoot"
	
	currentKatamari = KatamariControllable.instantiate()
	currentKatamari.Size = currentStage.modes.get(currentMode).katamari.size
	currentKatamari.Speed = currentStage.modes.get(currentMode).katamari.speed
	currentKatamari.CanDash = currentStage.modes.get(currentMode).katamari.can_dash
	currentKatamari.CanQuickTurn = currentStage.modes.get(currentMode).katamari.can_turn
	currentKatamari.CameraZones = currentStage.modes.get(currentMode).cam_zones
	currentKatamari.Music = GKGlobal.selectedMusic
	if not currentStage.modes.get(currentMode).katamari.can_dialogue_move: currentKatamari.MovementEnabled = false
	if currentStage.modes.get(currentMode).time > 0: 
		var currentTimer = TimerNormal.instantiate()
		currentTimer.maximum_time = currentStage.modes.get(currentMode).time
		currentTimer.time = currentStage.modes.get(currentMode).time
		currentKatamari.add_child(currentTimer)
	await preloadArea(0)
	await instantiateArea(0)
	
	stageRoot.add_child(currentKatamari)
	
	# INSTANTIATE TIMER HERE
	
	parent.add_child(stageRoot)
	stage_instantiated.emit()
	GKOverlays.load_end()

## Preloads an area, without adding it to the stage root.
func preloadArea(area:int = currentArea + 1):
	loadFinished = false
	
	for child in preloadRoot.get_children():
		child.queue_free()
	
	var currentStatics := Node3D.new()
	currentStatics.name = "static_%d"%[area]
	preloadRoot.add_child(currentStatics)
	
	for scene in currentStage.modes.get(currentMode).map_zones[area].static:
		ResourceLoader.load_threaded_request(scene[0])
		while ResourceLoader.load_threaded_get_status(scene[0]) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().create_timer(0.1).timeout
		var instantiated:Node = ResourceLoader.load_threaded_get(scene[0]).instantiate()
		instantiated.set_script(null)
		currentStatics.add_child(instantiated)
	
	var num:int = 0
	for object in currentStage.modes.get(currentMode).map_zones[area].objects:
		var instantiated:Node = RollableObject.instantiate()
		
		ResourceLoader.load_threaded_request(objectList.get(object.id, objectList["debug_cube"]).view_mesh)
		while ResourceLoader.load_threaded_get_status(objectList.get(object.id, objectList["debug_cube"]).view_mesh) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().create_timer(0.1).timeout
		ResourceLoader.load_threaded_request(objectList.get(object.id, objectList["debug_cube"]).collision_mesh)
		while ResourceLoader.load_threaded_get_status(objectList.get(object.id, objectList["debug_cube"]).collision_mesh) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().create_timer(0.1).timeout
		ResourceLoader.load_threaded_request(objectList.get(object.id, objectList["debug_cube"]).texture)
		while ResourceLoader.load_threaded_get_status(objectList.get(object.id, objectList["debug_cube"]).texture) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().create_timer(0.1).timeout
		ResourceLoader.load_threaded_request(objectList.get(object.id, objectList["debug_cube"]).texture_rolledup)
		while ResourceLoader.load_threaded_get_status(objectList.get(object.id, objectList["debug_cube"]).texture_rolledup) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().create_timer(0.1).timeout
		
		instantiated.InstanceName = str(area) + "_" + str(num)
		if ResourceLoader.exists(objectList.get(object.id, objectList["debug_cube"]).view_mesh): instantiated.ObjectMesh = ResourceLoader.load_threaded_get(objectList.get(object.id, "debug_cube").view_mesh)
		if ResourceLoader.exists(objectList.get(object.id, objectList["debug_cube"]).collision_mesh): instantiated.ObjectCol = ResourceLoader.load_threaded_get(objectList.get(object.id, "debug_cube").collision_mesh)
		instantiated.ObjectKnockSize = objectList.get(object.id, objectList["debug_cube"]).knock_size
		instantiated.ObjectRollSize = objectList.get(object.id, objectList["debug_cube"]).roll_size
		instantiated.ObjectGrowSize = objectList.get(object.id, objectList["debug_cube"]).pickup_size
		instantiated.ObjectTex = ResourceLoader.load_threaded_get(objectList.get(object.id, "debug_cube").texture) if objectList.get(object.id, "debug_cube").texture != "" else preload("uid://bo151m2ckmef3")
		instantiated.ObjectTexRoll = ResourceLoader.load_threaded_get(objectList.get(object.id, "debug_cube").texture_rolledup) if objectList.get(object.id, "debug_cube").texture_rolledup != "" else instantiated.ObjectTex
		instantiated.position = Vector3(object.position[0], object.position[1], object.position[2])
		instantiated.rotation = Vector3(object.rotation[0], object.rotation[1], object.rotation[2]) * (PI/180)
		instantiated.ObjectScale = objectList.get(object.id, "debug_cube").scale
		instantiated.AnimationName = object.animation if object.animation != "" else &"RESET"
		instantiated.AnimationSpeed = object.animation_speed
		instantiated.AnimationPhase = fmod(object.animation_phase, 1)
		
		preloadRoot.add_child(instantiated)
		
		num += 1
	loadFinished = true

## Instantiates a size area into the stage root.
func instantiateArea(area:int = currentArea + 1):
	if area != currentArea:
		currentArea = area
		await preloadArea(area)
	while not loadFinished:
		await get_tree().create_timer(0.1).timeout

	for child in preloadRoot.get_children():
		preloadRoot.remove_child(child)
		stageRoot.add_child(child)
	
	if stageRoot.get_node_or_null("static_%d"%[area-1]) != null:
		stageRoot.get_node("static_%d"%[area-1]).queue_free()
	
	var newScale = currentStage.modes.get(currentMode).map_zones[currentArea].scale
	stageRoot.scale = Vector3(newScale, newScale, newScale)
	
	currentKatamari.RoyalWarpHeight = currentStage.modes.get(currentMode).map_zones[currentArea].warp_height
	currentKatamari.SpawnPoints = currentStage.modes.get(currentMode).map_zones[currentArea].spawn_positions.map(func(pos): return Vector4(pos[0], pos[1], pos[2], pos[3]))
	currentKatamari.SoundSize = currentStage.modes.get(currentMode).map_zones[currentArea].audio_size
	currentKatamari.CoreModel = currentStage.modes.get(currentMode).map_zones[currentArea].core_model
	currentKatamari.CoreTexture = currentStage.modes.get(currentMode).map_zones[currentArea].core_texture
