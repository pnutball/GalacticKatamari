extends VSplitContainer

@onready var LevelTreeRoot:TreeItem = %LevelTree.create_item()

const Vector3Property:PackedScene = preload("res://editor/property_vector3.tscn")
const NumberProperty:PackedScene = preload("res://editor/property_number.tscn")
const StringProperty:PackedScene = preload("res://editor/property_string.tscn")

func _ready():
	LevelTreeRoot.set_text(0, "New File")
	LevelTreeRoot.set_icon(0, load("res://editor/icons/document.png"))
	


func _on_properties_list_changed():
	if %PropertiesPanel:
		$PropertiesScroll/PropertiesMargin/NoneSelectedLabel.visible = %PropertiesPanel.get_child_count() == 0
