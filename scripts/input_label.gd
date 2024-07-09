extends PanelContainer

# NOTE: The self-modulate colors for the panel are as follows:
# #5AC54F unchecked
# #F389F5 checked

## The names used by the input label.
##
## Each key should be the Godot Engine language code for the value (String)'s localized text.
## If a key doesn't exist for a language, it'll fall back to English.
@export var InputNameLocalized:Dictionary = {
	"en": ""
}

@export_group("Left Input")
## The first key used on the left side.
##
## Setting this to KEY_NONE hides the first key image.
@export var LeftInputKey1:Key = KEY_NONE
## The second key used on the left side.
##
## Setting this to KEY_NONE hides the second key image.
@export var LeftInputKey2:Key = KEY_NONE
## If true, uses the left stick vectors instead of the left input buttons.
@export var LeftIsStick:bool = true
## The button used for the left controller input when LeftIsStick is false.
@export var LeftInputController:GKGlobal.ControllerButton = GKGlobal.BUTTON_NONE
## The vector used for the left controller input when LeftIsStick is true.
@export var LeftInputVector:Vector2 = Vector2.ZERO
## If true, the left keys/buttons are pressed.
@export var LeftPressed:bool = false
var LeftTextureKey1:Texture2D
var LeftTextureKey2:Texture2D
var LeftTextureController:Texture2D

@export_subgroup("Alternate Input")
## The alternative first key used on the left side.
##
## Setting this to KEY_NONE will reuse LeftInputKey1.
@export var LeftAltInputKey1:Key = KEY_NONE
## The alternative second key used on the left side.
##
## Setting this to KEY_NONE will reuse LeftInputKey2.
@export var LeftAltInputKey2:Key = KEY_NONE
## The alternative button used for the left controller input when LeftIsStick is false.
@export var LeftAltInputController:GKGlobal.ControllerButton = GKGlobal.BUTTON_NONE
## The alternative vector used for the left controller input when LeftIsStick is true.
@export var LeftAltInputVector:Vector2 = Vector2.ZERO
## If true, the alternative left keys/buttons are pressed.
@export var LeftAltPressed:bool = false
var LeftAltTextureKey1:Texture2D
var LeftAltTextureKey2:Texture2D
var LeftAltTextureController:Texture2D

@export_group("Right Input")
## The first key used on the right side.
##
## Setting this to KEY_NONE hides the first key image.
@export var RightInputKey1:Key = KEY_NONE
## The second key used on the right side.
##
## Setting this to KEY_NONE hides the second key image.
@export var RightInputKey2:Key = KEY_NONE
## If true, uses the right stick vectors instead of the right input buttons.
@export var RightIsStick:bool = true
## The button used for the right controller input when LeftIsStick is false.
@export var RightInputController:GKGlobal.ControllerButton = GKGlobal.BUTTON_NONE
## The vector used for the right controller input when LeftIsStick is true.
@export var RightInputVector:Vector2 = Vector2.ZERO
## If true, the right keys/buttons are pressed.
@export var RightPressed:bool = false
var RightTextureKey1:Texture2D
var RightTextureKey2:Texture2D
var RightTextureController:Texture2D

@export_subgroup("Alternate Input")
## The alternative first key used on the right side.
##
## Setting this to KEY_NONE will reuse RightInputKey1.
@export var RightAltInputKey1:Key = KEY_NONE
## The alternative second key used on the right side.
##
## Setting this to KEY_NONE will reuse RightInputKey2.
@export var RightAltInputKey2:Key = KEY_NONE
## The alternative button used for the right controller input when LeftIsStick is false.
@export var RightAltInputController:GKGlobal.ControllerButton = GKGlobal.BUTTON_NONE
## The alternative vector used for the right controller input when LeftIsStick is true.
@export var RightAltInputVector:Vector2 = Vector2.ZERO
## If true, the alternative right keys/buttons are pressed.
@export var RightAltPressed:bool = false
var RightAltTextureKey1:Texture2D
var RightAltTextureKey2:Texture2D
var RightAltTextureController:Texture2D
var InternalTimer:float = 0:
	get:
		return InternalTimer
	set(new):
		InternalTimer = fmod(new, 1)
var AltTexturesOn:bool:
	get:
		return InternalTimer >= 0.5

func _ready():
	LeftTextureKey1 = GKGlobal.get_key(LeftInputKey1, LeftPressed)
	LeftTextureKey2 = GKGlobal.get_key(LeftInputKey2, LeftPressed)
	LeftAltTextureKey1 = GKGlobal.get_key(LeftAltInputKey1 if LeftAltInputKey1 != KEY_NONE else LeftInputKey1, LeftAltPressed)
	LeftAltTextureKey2 = GKGlobal.get_key(LeftAltInputKey2 if LeftAltInputKey2 != KEY_NONE else LeftInputKey2, LeftAltPressed)
	RightTextureKey1 = GKGlobal.get_key(RightInputKey1, RightPressed)
	RightTextureKey2 = GKGlobal.get_key(RightInputKey2, RightPressed)
	RightAltTextureKey1 = GKGlobal.get_key(RightAltInputKey1 if RightAltInputKey1 != KEY_NONE else RightInputKey1, RightAltPressed)
	RightAltTextureKey2 = GKGlobal.get_key(RightAltInputKey2 if RightAltInputKey2 != KEY_NONE else RightInputKey2, RightAltPressed)
	
	_reload_controller_buttons()
	
	GKGlobal.controller_changed.connect(_conditional_button_reload)

func _process(delta):
	InternalTimer += delta
	$ControlVbox/ControlLabel.text = GKGlobal.get_localized_string(InputNameLocalized)
	if not GKGlobal.usingController:
		$ControlVbox/InputIconHbox/LeftInputBox/Tex1.texture = LeftAltTextureKey1 if AltTexturesOn else LeftTextureKey1
		$ControlVbox/InputIconHbox/LeftInputBox/Tex1.visible = LeftAltInputKey1 != KEY_NONE or LeftInputKey1 != KEY_NONE
		$ControlVbox/InputIconHbox/LeftInputBox/Tex2.texture = LeftAltTextureKey2 if AltTexturesOn else LeftTextureKey2
		$ControlVbox/InputIconHbox/LeftInputBox/Tex2.visible = LeftAltInputKey2 != KEY_NONE or LeftInputKey2 != KEY_NONE
		$ControlVbox/InputIconHbox/LeftInputBox.visible = $ControlVbox/InputIconHbox/LeftInputBox/Tex1.visible or $ControlVbox/InputIconHbox/LeftInputBox/Tex2.visible
		$ControlVbox/InputIconHbox/RightInputBox/Tex1.texture = RightAltTextureKey1 if AltTexturesOn else RightTextureKey1
		$ControlVbox/InputIconHbox/RightInputBox/Tex1.visible = RightAltInputKey1 != KEY_NONE or RightInputKey1 != KEY_NONE
		$ControlVbox/InputIconHbox/RightInputBox/Tex2.texture = RightAltTextureKey2 if AltTexturesOn else RightTextureKey2
		$ControlVbox/InputIconHbox/RightInputBox/Tex2.visible = RightAltInputKey2 != KEY_NONE or RightInputKey2 != KEY_NONE
		$ControlVbox/InputIconHbox/RightInputBox.visible = $ControlVbox/InputIconHbox/RightInputBox/Tex1.visible or $ControlVbox/InputIconHbox/RightInputBox/Tex2.visible
	else:
		$ControlVbox/InputIconHbox/LeftInputBox/Tex1.texture = LeftAltTextureController if AltTexturesOn else LeftTextureController
		$ControlVbox/InputIconHbox/LeftInputBox/Tex1.visible = LeftAltInputController != GKGlobal.BUTTON_NONE or LeftInputController != GKGlobal.BUTTON_NONE or LeftIsStick
		$ControlVbox/InputIconHbox/LeftInputBox.visible = $ControlVbox/InputIconHbox/LeftInputBox/Tex1.visible
		$ControlVbox/InputIconHbox/LeftInputBox/Tex2.visible = false
		$ControlVbox/InputIconHbox/RightInputBox/Tex1.texture = RightAltTextureController if AltTexturesOn else RightTextureController
		$ControlVbox/InputIconHbox/RightInputBox/Tex1.visible = RightAltInputController != GKGlobal.BUTTON_NONE or RightInputController != GKGlobal.BUTTON_NONE or RightIsStick
		$ControlVbox/InputIconHbox/RightInputBox.visible = $ControlVbox/InputIconHbox/RightInputBox/Tex1.visible
		$ControlVbox/InputIconHbox/RightInputBox/Tex2.visible = false

func reset_timer():
	InternalTimer = 0

func _conditional_button_reload(index:int):
	if index == 0: 
		_reload_controller_buttons()

func _reload_controller_buttons():
	if LeftIsStick: 
		LeftTextureController = GKGlobal.get_stick(false, LeftInputVector, GKGlobal.get_brand())
		LeftAltTextureController = GKGlobal.get_stick(false, LeftAltInputVector if LeftAltInputVector != Vector2.ZERO else LeftInputVector, GKGlobal.get_brand())
	else: 
		LeftTextureController = GKGlobal.get_button(LeftInputController, LeftPressed, GKGlobal.get_brand())
		LeftAltTextureController = GKGlobal.get_button(LeftAltInputController if LeftAltInputController != GKGlobal.BUTTON_NONE else LeftInputController, LeftAltPressed, GKGlobal.get_brand())
	
	if RightIsStick: 
		RightTextureController = GKGlobal.get_stick(true, RightInputVector, GKGlobal.get_brand())
		RightAltTextureController = GKGlobal.get_stick(true, RightAltInputVector if RightAltInputVector != Vector2.ZERO else RightInputVector, GKGlobal.get_brand())
	else: 
		RightTextureController = GKGlobal.get_button(RightInputController, RightPressed, GKGlobal.get_brand())
		RightAltTextureController = GKGlobal.get_button(RightAltInputController if RightAltInputController != GKGlobal.BUTTON_NONE else RightInputController, RightAltPressed, GKGlobal.get_brand())
