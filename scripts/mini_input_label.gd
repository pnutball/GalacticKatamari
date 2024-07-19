extends HBoxContainer

## The names used by the input label.
##
## Each key should be the Godot Engine language code for the value (String)'s localized text.
## If a key doesn't exist for a language, it'll fall back to English.
@export var InputNameLocalized:Dictionary = {
	"en": ""
}

@export_group("Input")
## The key used.
##
## Setting this to KEY_NONE hides the key.
@export var InputKey:Key = KEY_NONE
## If true, uses the left stick vectors instead of the left input buttons.
@export var IsStick:bool = true
## The button used for the left controller input when LeftIsStick is false.
@export var InputController:GKGlobal.ControllerButton = GKGlobal.BUTTON_NONE
## The vector used for the left controller input when LeftIsStick is true.
@export var InputVector:Vector2 = Vector2.ZERO
## If true, the left key/button is pressed.
@export var Pressed:bool = false
var TextureKey:Texture2D
var TextureController:Texture2D

func _ready():
	TextureKey = GKGlobal.get_key(InputKey, Pressed)
	
	_reload_controller_buttons()
	
	GKGlobal.controller_changed.connect(_conditional_button_reload)

func _process(_delta):
	$ControlLabel.text = GKGlobal.get_localized_string(InputNameLocalized)
	if not GKGlobal.usingController:
		$ControlTexture.texture = TextureKey
		$ControlTexture.visible = InputKey != KEY_NONE
	else:
		$ControlTexture.texture = TextureController
		$ControlTexture.visible = InputController != GKGlobal.BUTTON_NONE or IsStick

func _conditional_button_reload(index:int):
	if index == 0: 
		_reload_controller_buttons()

func _reload_controller_buttons():
	if IsStick: 
		TextureController = GKGlobal.get_stick(false, InputVector, GKGlobal.get_brand())
	else: 
		TextureController = GKGlobal.get_button(InputController, Pressed, GKGlobal.get_brand())
