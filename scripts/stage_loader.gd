extends Node

var objectList:Dictionary = preload("res://data/objects.json").data
var RollableObject3D:PackedScene = preload("res://scenes/game/object/rollable_object_3d.tscn")
var currentStage:Dictionary

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS

## Loads a stage's JSON data into currentStage.
##
## path: The path to the .gkl.json file containing the level.
## name: The level's internal name.
func loadStage(path:String, name:String):
	if not path.ends_with(".gkl.json"):
		return ERR_FILE_BAD_PATH
	ResourceLoader.load_threaded_request(path)
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().create_timer(0.1).timeout
	if ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_LOADED:
		return ERR_FILE_CANT_OPEN
	else:
		var json = ResourceLoader.load_threaded_get(path)
		if "levels" in json.data and name in json.data.levels:
			currentStage = json.data.levels.get(name)
		else:
			return ERR_FILE_CANT_READ

## Instantiates the currently loaded stage.
##
## mode: The level's mode.
## parent: The node that the stage root node is parented to.
func instantiateStage(mode:String, parent:Node = get_tree().get_root()):
	var stageRoot = Node3D.new()
	stageRoot.name = "KatamariStageRoot"

	for scene in currentStage.modes.get(mode).map_zones[0].static:
		ResourceLoader.load_threaded_request(scene)
		while ResourceLoader.load_threaded_get_status(scene) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().create_timer(0.1).timeout
		var instantiated:Node = ResourceLoader.load_threaded_get(scene).instantiate()
		stageRoot.add_child(instantiated)
	
	var num:int = 0
	for object in currentStage.modes.get(mode).map_zones[0].objects:
		var instantiated:Node = RollableObject3D.instantiate()
		
		ResourceLoader.load_threaded_request(objectList.objects.get(object.id).view_mesh)
		while ResourceLoader.load_threaded_get_status(objectList.objects.get(object.id).view_mesh) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().create_timer(0.1).timeout
		ResourceLoader.load_threaded_request(objectList.objects.get(object.id).collision_mesh)
		while ResourceLoader.load_threaded_get_status(objectList.objects.get(object.id).collision_mesh) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().create_timer(0.1).timeout
		
		instantiated.InstanceName = str(num)
		instantiated.ObjectName = objectList.objects.get(object.id).name.en
		instantiated.ObjectMesh = ResourceLoader.load_threaded_get(objectList.objects.get(object.id).view_mesh)
		instantiated.ObjectCol = ResourceLoader.load_threaded_get(objectList.objects.get(object.id).collision_mesh)
		instantiated.position = Vector3(object.position[0], object.position[1], object.position[2])
		instantiated.rotation = Vector3(object.rotation[0], object.rotation[1], object.rotation[2])
		instantiated.scale = Vector3(object.scale, object.scale, object.scale)
		
		stageRoot.add_child(instantiated)
		
		num += 1
	
	# INSTANTIATE KATAMARI HERE
