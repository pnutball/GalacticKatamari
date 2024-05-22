extends SubViewportContainer
const view_spawn:PackedScene = preload("res://editor/3d_items/3d_view_spawn.tscn")
const view_stat:PackedScene = preload("res://editor/3d_items/3d_view_static.tscn")

func reload_statics():
	for stat in $ViewPort/EditorPrevRoot/statics.get_children():
		stat.queue_free()
	for stat in %SplitLeft.lastSelectedArea.get_meta(&"path").static:
		var ViewStat:Node3D = view_stat.instantiate()
		ViewStat.SpawnArray = stat
		$ViewPort/EditorPrevRoot/statics.add_child(ViewStat)

func reload_objects():
	#$EditorViewport/EditorPrevRoot/objects
	for obj in %SplitLeft.lastSelectedArea.get_meta(&"path").objects:
		print(obj)

func reload_spawns():
	#$EditorViewport/EditorPrevRoot/spawns
	for spawn in $ViewPort/EditorPrevRoot/spawns.get_children():
		spawn.queue_free()
	for spawn in %SplitLeft.lastSelectedArea.get_meta(&"path").spawn_positions:
		var ViewSpawn:Node3D = view_spawn.instantiate()
		ViewSpawn.TransformArray = spawn
		$ViewPort/EditorPrevRoot/spawns.add_child(ViewSpawn)

func _gui_input(event):
	$ViewPort/EditorPrevRoot/EditorCamera.input(event)
