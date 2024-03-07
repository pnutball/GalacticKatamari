extends VSplitContainer

func _ready():
	var root = %LevelTree.create_item()
	root.set_text(0, "New File")
	root.set_icon(0, load("res://editor/icons/document.png"))
	
