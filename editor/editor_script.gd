extends Control

func _ready():
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_tree().root.get_node("FPSCounter").visible = false
