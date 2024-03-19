extends Node

signal stage_loaded
signal stage_instantiated

var objectList:Dictionary = preload("res://data/objects.json").data
var currentStage:Dictionary
var currentMode:String
var currentArea:int = 0
var stageRoot:Node3D
var currentKatamari

const RollableObject3D:PackedScene = preload("res://scenes/game/object/rollable_object_3d.tscn")
const KatamariControllable:PackedScene = preload("res://scenes/game/object/katamari_controllable.tscn")

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS

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

## Get the currently loaded stage's modes.
func getModes():
	return currentStage.modes.keys()

## Instantiates the currently loaded stage.
##
## mode: The level's mode.
## parent: The node that the stage root node is parented to.
func instantiateStage(mode:String, parent:Node = get_tree().get_root()):
	currentMode = mode
	stageRoot = Node3D.new()
	stageRoot.name = "KatamariStageRoot"
	
	currentKatamari = KatamariControllable.instantiate()
	currentKatamari.Size = currentStage.modes.get(currentMode).katamari.size
	currentKatamari.Speed = currentStage.modes.get(currentMode).katamari.speed
	currentKatamari.CanDash = currentStage.modes.get(currentMode).katamari.can_dash
	currentKatamari.CanQuickTurn = currentStage.modes.get(currentMode).katamari.can_turn
	currentKatamari.CameraRotation = currentStage.modes.get(currentMode).katamari.cam_rotation
	currentKatamari.CameraZones = currentStage.modes.get(currentMode).cam_zones
	
	await instantiateArea(0)
	
	stageRoot.add_child(currentKatamari)
	
	# INSTANTIATE TIMER HERE
	
	parent.add_child(stageRoot)
	stage_instantiated.emit()

func instantiateArea(area:int = currentArea + 1):
	currentArea = area
	if not (stageRoot.get_node_or_null("static") == null):
		stageRoot.static.queue_free()
	
	var currentStatics := Node3D.new()
	currentStatics.name = "static"
	stageRoot.add_child(currentStatics)
	
	for scene in currentStage.modes.get(currentMode).map_zones[currentArea].static:
		ResourceLoader.load_threaded_request(scene)
		while ResourceLoader.load_threaded_get_status(scene) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().create_timer(0.1).timeout
		var instantiated:Node = ResourceLoader.load_threaded_get(scene).instantiate()
		currentStatics.add_child(instantiated)
	
	var num:int = 0
	for object in currentStage.modes.get(currentMode).map_zones[currentArea].objects:
		var instantiated:Node = RollableObject3D.instantiate()
		
		ResourceLoader.load_threaded_request(objectList.objects.get(object.id).view_mesh)
		while ResourceLoader.load_threaded_get_status(objectList.objects.get(object.id).view_mesh) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().create_timer(0.1).timeout
		ResourceLoader.load_threaded_request(objectList.objects.get(object.id).collision_mesh)
		while ResourceLoader.load_threaded_get_status(objectList.objects.get(object.id).collision_mesh) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().create_timer(0.1).timeout
		
		instantiated.InstanceName = str(currentArea) + "_" + str(num)
		instantiated.ObjectName = objectList.objects.get(object.id).name.en
		instantiated.ObjectMesh = ResourceLoader.load_threaded_get(objectList.objects.get(object.id).view_mesh)
		instantiated.ObjectCol = ResourceLoader.load_threaded_get(objectList.objects.get(object.id).collision_mesh)
		instantiated.position = Vector3(object.position[0], object.position[1], object.position[2])
		instantiated.rotation = Vector3(object.rotation[0], object.rotation[1], object.rotation[2])
		instantiated.scale = Vector3(object.scale, object.scale, object.scale)
		
		stageRoot.add_child(instantiated)
		
		num += 1
	
	currentKatamari.RoyalWarpHeight = currentStage.modes.get(currentMode).map_zones[currentArea].warp_height
	currentKatamari.SpawnPoints = currentStage.modes.get(currentMode).map_zones[currentArea].spawn_positions.map(func(pos): return Vector3(pos[0], pos[1], pos[2]))
	currentKatamari.SoundSize = currentStage.modes.get(currentMode).map_zones[currentArea].audio_size
	currentKatamari.CoreModel = currentStage.modes.get(currentMode).map_zones[currentArea].core_model
	currentKatamari.CoreTexture = currentStage.modes.get(currentMode).map_zones[currentArea].core_texture
