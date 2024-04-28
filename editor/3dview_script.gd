extends SubViewportContainer

func reload_statics():
	#$EditorViewport/EditorPrevRoot/statics
	for stat in %SplitLeft.lastSelectedArea.get_meta(&"path").static:
		print(stat)

func reload_objects():
	#$EditorViewport/EditorPrevRoot/objects
	for obj in %SplitLeft.lastSelectedArea.get_meta(&"path").objects:
		print(obj)

func reload_spawns():
	#$EditorViewport/EditorPrevRoot/spawns
	for spawn in %SplitLeft.lastSelectedArea.get_meta(&"path").spawn_positions:
		print(spawn)
