extends SubViewportContainer
const view_spawn:PackedScene = preload("res://editor/3d_items/3d_view_spawn.tscn")
const view_stat:PackedScene = preload("res://editor/3d_items/3d_view_static.tscn")
const view_obj:PackedScene = preload("res://editor/3d_items/3d_view_object.tscn")

func reload_statics():
	for stat in $ViewPort/EditorPrevRoot/statics.get_children():
		stat.queue_free()
	for stat in %SplitLeft.lastSelectedArea.children:
		if stat is GKEditorTreeStatic:
			var ViewStat:Node3D = view_stat.instantiate()
			ViewStat.Source = stat
			$ViewPort/EditorPrevRoot/statics.add_child(ViewStat)

func reload_objects():
	#$EditorViewport/EditorPrevRoot/objects
	for obj in $ViewPort/EditorPrevRoot/objects.get_children():
		obj.queue_free()
	for obj in %SplitLeft.lastSelectedArea.children:
		if obj is GKEditorTreeObject:
			var ViewObj:Node3D = view_obj.instantiate()
			obj.linked_3d = ViewObj
			ViewObj.Source = obj
			$ViewPort/EditorPrevRoot/objects.add_child(ViewObj)

func reload_spawns():
	#$EditorViewport/EditorPrevRoot/spawns
	for spawn in $ViewPort/EditorPrevRoot/spawns.get_children():
		spawn.queue_free()
	for spawn in %SplitLeft.lastSelectedArea.children:
		if spawn is GKEditorTreeSpawn:
			var ViewSpawn:Node3D = view_spawn.instantiate()
			spawn.linked_3d = ViewSpawn
			ViewSpawn.Source = spawn
			$ViewPort/EditorPrevRoot/spawns.add_child(ViewSpawn)

func reload_all():
	for stat in $ViewPort/EditorPrevRoot/statics.get_children():
		stat.queue_free()
	for obj in $ViewPort/EditorPrevRoot/objects.get_children():
		obj.queue_free()
	for spawn in $ViewPort/EditorPrevRoot/spawns.get_children():
		spawn.queue_free()
	for child in %SplitLeft.lastSelectedArea.children:
		if child is GKEditorTreeStatic:
			var ViewStat:Node3D = view_stat.instantiate()
			ViewStat.Source = child
			$ViewPort/EditorPrevRoot/statics.add_child(ViewStat)
		elif child is GKEditorTreeSpawn:
			var ViewSpawn:Node3D = view_spawn.instantiate()
			child.linked_3d = ViewSpawn
			ViewSpawn.Source = child
			$ViewPort/EditorPrevRoot/spawns.add_child(ViewSpawn)
		elif child is GKEditorTreeObject:
			var ViewObj:Node3D = view_obj.instantiate()
			child.linked_3d = ViewObj
			ViewObj.Source = child
			$ViewPort/EditorPrevRoot/objects.add_child(ViewObj)

func _gui_input(event):
	$ViewPort/EditorPrevRoot/EditorCamera.input(event)
