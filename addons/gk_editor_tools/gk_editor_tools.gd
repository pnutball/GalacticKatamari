@tool
class_name GKEditorToolsPlugin
extends EditorPlugin

## The ID of the "Export as GK Level" menu item.
const EXPORT_ENTRY_ID:int = 31804

func _enter_tree():
	# Initialization of the plugin goes here.
	get_export_as_menu().add_item("Galactic Katamari Level...", EXPORT_ENTRY_ID)
	get_export_as_menu().set_item_metadata(get_export_as_menu().get_item_index(EXPORT_ENTRY_ID), _export_gkl)
	get_export_as_menu().set_item_tooltip(get_export_as_menu().get_item_index(EXPORT_ENTRY_ID), "Hold Shift to force Export As mode.")
	if not ProjectSettings.has_setting("plugins/gk_tools/object_data_folder"):
		ProjectSettings.set_setting("plugins/gk_tools/object_data_folder", "res://data")
		ProjectSettings.save()
	ProjectSettings.add_property_info({
		"name": "plugins/gk_tools/object_data_folder",
		"description": "The folder containing objects.json and collection.json.\nIf invalid, objects will not appear in-editor.",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_DIR
	})
	ProjectSettings.set_initial_value("plugins/gk_tools/object_data_folder", "res://data")
	ProjectSettings.set_as_basic("plugins/gk_tools/object_data_folder", true)

func _process(_delta):
	if get_export_as_menu().get_item_index(EXPORT_ENTRY_ID) != null:
		get_export_as_menu().set_item_disabled(get_export_as_menu().get_item_index(EXPORT_ENTRY_ID), 
		not EditorInterface.get_edited_scene_root() is GKLevel or false)

func _exit_tree():
	# Clean-up of the plugin goes here.
	get_export_as_menu().remove_item(get_export_as_menu().get_item_index(EXPORT_ENTRY_ID))


func _export_gkl(force_export_as:bool = false):
	if not EditorInterface.get_edited_scene_root() is GKLevel:
		printerr("Error: scene root isn't a GKLevel node and can't be converted to a gkl.json")
	else:
		if force_export_as or Input.is_key_label_pressed(KEY_SHIFT) or EditorInterface.get_edited_scene_root().export_path.is_empty():
			var export_save := EditorFileDialog.new()
			export_save.filters = ["*.gkl.json ; Galactic Katamari Level"]
			export_save.display_mode = EditorFileDialog.DISPLAY_LIST
			export_save.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
			export_save.access = EditorFileDialog.ACCESS_FILESYSTEM
			export_save.title = "Export As"
			export_save.ok_button_text = "Export"
			export_save.file_selected.connect(export_dialog_handler)
			export_save.canceled.connect(export_dialog_handler)
			EditorInterface.popup_dialog_centered(export_save, Vector2i(1050,700))
			var should_return = await export_dialog_closed
			export_save.file_selected.disconnect(export_dialog_handler)
			export_save.canceled.disconnect(export_dialog_handler)
			export_save.queue_free()
			if should_return: return
		var file = FileAccess.open(EditorInterface.get_edited_scene_root().export_path, FileAccess.WRITE)
		if file == null:
			printerr("Couldn't export file: %s"%error_string(FileAccess.get_open_error()))
			return
		file.store_string(JSON.stringify({"levels":EditorInterface.get_edited_scene_root().to_json()}, "\t"))
		file.close()
		print("Level exported successfully to \'%s\'"%EditorInterface.get_edited_scene_root().export_path)

signal export_dialog_closed(path_empty:bool)

func export_dialog_handler(path:String = "") -> void:
	if not path.is_empty():
		EditorInterface.get_edited_scene_root().export_path = path
	export_dialog_closed.emit(path.is_empty())
	return
