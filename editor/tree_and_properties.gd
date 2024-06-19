extends VSplitContainer

signal ChangeMade

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

var lastSelectedLevel:GKEditorTreeLevel
var lastSelectedMode:GKEditorTreeMode
var lastSelectedArea:GKEditorTreeArea

@onready var TreeRoot:TreeItem = %LevelTree.create_item()
var InternalTreeRoot := GKEditorTreeRoot.new()

func resetTree():
	TreeRoot.set_text(0, "New File")
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

func _ready():
	TreeRoot.set_text(0, "New File")
	TreeRoot.set_icon(0, load("res://editor/icons/document.png"))
	TreeRoot.set_selectable(0, false)
	ChangeMade.connect(InternalTreeRoot.tree_sync.bind(TreeRoot))
	
	
func _on_create_id_pressed(id):
	match id:
		0: 
			#addLevel()
			var new_level := GKEditorTreeLevel.new()
			var level_id_no:int = 0
			var level_id_conflicts:bool = false
			while true:
				for child:GKEditorTreeLevel in InternalTreeRoot.children:
					if child.level_id == "level%d"%level_id_no:
						level_id_conflicts = true
						break
				if not level_id_conflicts:
					break
				level_id_conflicts = false
				level_id_no += 1
			new_level.level_id = "level%d"%level_id_no
			InternalTreeRoot.add_child(new_level)
			lastSelectedLevel = new_level
			_on_create_id_pressed(1)
		1: 
			#addMode(lastSelectedLevel)
			var new_mode := GKEditorTreeMode.new()
			var mode_id_no:int = -1
			var mode_id_conflicts:bool = false
			while true:
				for child:GKEditorTreeMode in lastSelectedLevel.children:
					if child.mode_id == ("level%d"%mode_id_no if mode_id_no > -1 else "normal"):
						mode_id_conflicts = true
						break
				if not mode_id_conflicts:
					break
				mode_id_conflicts = false
				mode_id_no += 1
			new_mode.mode_id = ("level%d"%mode_id_no if mode_id_no > -1 else "normal")
			lastSelectedLevel.add_child(new_mode)
			lastSelectedMode = new_mode
			_on_create_id_pressed(2)
			_on_create_id_pressed(3)
		2: 
			#addCameraZone(lastSelectedMode)
			var new_zone := GKEditorTreeCamZone.new()
			lastSelectedMode.add_child(new_zone)
		3: 
			#addSizeArea(lastSelectedMode)
			var new_zone := GKEditorTreeArea.new()
			lastSelectedMode.add_child(new_zone)
			lastSelectedArea = new_zone
		4: 
			#addStatic(lastSelectedArea)
			var new_stat := GKEditorTreeStatic.new()
			lastSelectedArea.add_child(new_stat)
		5: 
			#addObject(lastSelectedArea, %ObjectBrowser/ObjectScroll/ObjectList.get_item_text(%ObjectBrowser/ObjectScroll/ObjectList.get_selected_items()[0]))
			var new_obj := GKEditorTreeObject.new()
			new_obj.object_id = %ObjectBrowser/ObjectScroll/ObjectList.get_item_text(%ObjectBrowser/ObjectScroll/ObjectList.get_selected_items()[0])
			lastSelectedArea.add_child(new_obj)
		6: 
			#addSpawn(lastSelectedArea)
			var new_spawn := GKEditorTreeSpawn.new()
			lastSelectedArea.add_child(new_spawn)
	ChangeMade.emit()

func _on_level_tree_item_selected():
	for child in %PropertiesPanel.get_children():
		child.queue_free()
	$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = true
	var item:TreeItem = %LevelTree.get_selected()
	if item.has_meta(&"property"):
		var property:GKEditorTreeItem = item.get_meta(&"property")
		if property is GKEditorTreeLevel:
			%Create/Mode.disabled = false
			%Create/CamArea.disabled = true
			%Create/SizeArea.disabled = true
			%Create/Spawn.disabled = true
			%Create/Static.disabled = true
			%ObjectBrowser/InfoPanel/InfoPanelMargin/InfoPanelVbox/Object.disabled = true
			lastSelectedLevel = property
		elif property is GKEditorTreeMode:
			%Create/Mode.disabled = true
			%Create/CamArea.disabled = false
			%Create/SizeArea.disabled = false
			%Create/Spawn.disabled = true
			%Create/Static.disabled = true
			%ObjectBrowser/InfoPanel/InfoPanelMargin/InfoPanelVbox/Object.disabled = true
			lastSelectedMode = property
			lastSelectedLevel = property.parent
		elif property is GKEditorTreeArea:
			%Create/Mode.disabled = true
			%Create/CamArea.disabled = true
			%Create/SizeArea.disabled = true
			%Create/Spawn.disabled = false
			%Create/Static.disabled = false
			%ObjectBrowser/InfoPanel/InfoPanelMargin/InfoPanelVbox/Object.disabled = false
			lastSelectedArea = property
			lastSelectedMode = property.parent
			lastSelectedLevel = property.parent.parent
			%PlayButton.disabled = false
		elif property is GKEditorTreeObject:
			%Create/Mode.disabled = true
			%Create/CamArea.disabled = true
			%Create/SizeArea.disabled = true
			%Create/Spawn.disabled = true
			%Create/Static.disabled = true
			%ObjectBrowser/InfoPanel/InfoPanelMargin/InfoPanelVbox/Object.disabled = false
		else:
			%Create/Mode.disabled = true
			%Create/CamArea.disabled = true
			%Create/SizeArea.disabled = true
			%Create/Spawn.disabled = true
			%Create/Static.disabled = true
			%ObjectBrowser/InfoPanel/InfoPanelMargin/InfoPanelVbox/Object.disabled = true
		property.send_properties(%PropertiesPanel)
		$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = false

func openDict(dict:Dictionary):
	resetTree()
	lastSelectedLevel = null
	lastSelectedMode = null
	lastSelectedArea = null
	InternalTreeRoot = GKEditorTreeRoot.from_json(dict)
	InternalTreeRoot.tree_sync(TreeRoot)

func emitChange(): ChangeMade.emit()
