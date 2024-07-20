extends Control

@export var TextShown = true
const INFO_TEXT:String = "This game is played with both %s.\n(If you don't know this, why are you\neven doing a Katamari month?)"

func _ready():
	GKGlobal.controller_changed.connect(_refresh_image)
	$HBoxContainer/Middle/VBoxContainer/InfoLabel.visible = TextShown
	_refresh_image()

func _process(_delta):
	$HBoxContainer/Middle/VBoxContainer/InfoLabel.text = INFO_TEXT % ("sticks" if GKGlobal.usingController else "WASD and IJKL")

func _refresh_image(device:int = 0):
	if device == 0: 
		$HBoxContainer/Middle/VBoxContainer/ControllerTexture.texture = GKGlobal.get_controller_texture()
	$HBoxContainer/Middle/TopControls/Vibrate.modulate = Color(1,1,1,int(GKGlobal.usingController))
