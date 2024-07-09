extends Control

@export var TextShown = true

func _ready():
	GKGlobal.controller_changed.connect(_refresh_image)
	$HBoxContainer/Middle/VBoxContainer/InfoLabel.visible = TextShown
	_refresh_image()

func _refresh_image(device:int = 0):
	if device == 0: 
		$HBoxContainer/Middle/VBoxContainer/ControllerTexture.texture = GKGlobal.get_controller_texture()
	$HBoxContainer/Middle/TopControls/Vibrate.modulate = Color(1,1,1,int(GKGlobal.usingController))
