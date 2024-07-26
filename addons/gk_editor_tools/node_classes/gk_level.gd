@tool
@icon("res://addons/gk_editor_tools/icons/gk_level.svg")
extends Node
class_name GKLevel

## The stage's export path.
##
## If blank, exporting this level to JSON will forcibly show the export-as dialog.
@export_global_file(".gkl.json") var export_path:String = ""

## The stage's localized name. 
## 
## Each entry is the internal language code & the corresponding text string.
@export var level_name:Dictionary = {"en": "New level"}
## The stage's localized description. 
## 
## Each entry is the internal language code & the corresponding text string.
@export var level_description:Dictionary = {"en": "Enter a description here"}

## Returns a JSON-compatible representation of this tree item and its children.
func to_json():
	var modes_dict:Dictionary = {}
	for child in get_children():
		if child is GKMode:
			modes_dict[child.name] = child.to_json()
	var dict:Dictionary = {
		str(name): {
			"name": level_name,
			"description": level_description,
			"modes": modes_dict
		}
	}
	return dict
