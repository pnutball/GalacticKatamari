extends SubViewportContainer

func reload_statics():
	for stat in $ViewPort/EditorPrevRoot/statics.get_children():
		stat.queue_free()
	for stat in %SplitLeft.lastSelectedArea.get_meta(&"path").static:
		$ViewPort/EditorPrevRoot/statics.add_child(load(stat[0]).instantiate())

func reload_objects():
	#$EditorViewport/EditorPrevRoot/objects
	for obj in %SplitLeft.lastSelectedArea.get_meta(&"path").objects:
		print(obj)

func reload_spawns():
	#$EditorViewport/EditorPrevRoot/spawns
	for spawn in %SplitLeft.lastSelectedArea.get_meta(&"path").spawn_positions:
		print(spawn)

func _gui_input(event):
	$ViewPort/EditorPrevRoot/EditorCamera.input(event)
